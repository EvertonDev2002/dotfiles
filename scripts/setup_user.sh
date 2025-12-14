#!/bin/bash
# ============================================================================
#  SETUP USER - Configura sudo e grupos do usuário
#  Adiciona usuário aos grupos necessários e configura sudo sem senha
# ============================================================================

set -euo pipefail

# --- Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Funções de log
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

# --- Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    error "Este script precisa ser executado como root (sudo)"
    echo "Uso: sudo $0"
    exit 1
fi

# --- Detectar usuário real (quem executou sudo)
REAL_USER="${SUDO_USER:-$USER}"

if [ "$REAL_USER" = "root" ]; then
    error "Não execute este script diretamente como root"
    echo "Execute: sudo $0 (como usuário normal)"
    exit 1
fi

log "Configurando usuário: $REAL_USER"
echo ""

# Documentação: https://wiki.archlinux.org/title/users_and_groups
GROUPS_TO_ADD=(
    "wheel"        # Sudo/administração
    "video"        # Acesso a dispositivos de vídeo (GPU)
    "audio"        # Acesso a dispositivos de áudio
    "input"        # Acesso a dispositivos de input (teclado, mouse)
    "storage"      # Acesso a dispositivos de armazenamento removíveis
    "network"      # Gerenciamento de rede (NetworkManager)
    "power"        # Gerenciamento de energia (suspend, hibernate)
    "rfkill"       # Controle de dispositivos wireless
    "seat"         # Acesso ao seatd (sessões Wayland)
    "docker"       # Acesso ao Docker (se instalado)
)

# --- Adicionar usuário aos grupos
log "Adicionando $REAL_USER aos grupos necessários..."
echo ""

for group in "${GROUPS_TO_ADD[@]}"; do
    # Verificar se o grupo existe
    if getent group "$group" > /dev/null 2>&1; then
        # Verificar se usuário já está no grupo
        if id -nG "$REAL_USER" | grep -qw "$group"; then
            echo " -> $group: já membro ✓"
        else
            # Adicionar ao grupo
            if usermod -aG "$group" "$REAL_USER"; then
                success "$group: adicionado"
            else
                warn "$group: falha ao adicionar"
            fi
        fi
    else
        warn "$group: grupo não existe (pacote não instalado?)"
    fi
done

echo ""

# --- Configurar Sudo
log "Configurando sudo para $REAL_USER..."

# Verificar se usuário está no grupo wheel
if ! id -nG "$REAL_USER" | grep -qw "wheel"; then
    warn "Usuário não está no grupo 'wheel'. Adicionando..."
    usermod -aG wheel "$REAL_USER"
fi

# Descomente apenas a linha para sudo com senha no /etc/sudoers
if grep -q "^## %wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    log "Descomentando linha wheel no /etc/sudoers..."
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    
    if visudo -c > /dev/null 2>&1; then
        success "Configuração sudoers atualizada (sudo COM senha)"
    else
        error "Erro na sintaxe do sudoers! Revertendo..."
        sed -i 's/^%wheel ALL=(ALL:ALL) ALL/# %wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
        exit 1
    fi
elif grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    success "Linha wheel já descomentada no /etc/sudoers"
else
    warn "Linha wheel não encontrada em /etc/sudoers"
fi

echo ""
success "Configuração concluída!"
echo ""
echo "Detalhes:"
echo "  Usuário: $REAL_USER"
echo "  Grupos: $(id -nG "$REAL_USER" | tr ' ' ', ')"
echo "  Sudo: Com senha (descomentado em /etc/sudoers)"
echo ""
warn "IMPORTANTE: Faça logout e login novamente para aplicar as mudanças de grupo!"
echo ""
echo "Próximos passos:"
echo "  1. Abra um novo terminal (logout/login)"
echo "  2. Teste: sudo -v (pedirá senha)"
echo ""
echo "Recomendação de segurança:"
echo "  Para DESABILITAR acesso root no Display Manager (DM),"
echo "  Use: passwd -l root"
echo ""
