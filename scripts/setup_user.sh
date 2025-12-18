#!/bin/bash
#  SETUP USER - Configura sudo e grupos do usuário
#  Adiciona usuário aos grupos necessários e configura sudo com senha

set -euo pipefail

# --- Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Funções de log
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# --- Pedir sudo se necessário
if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

# --- Pedir nome do usuário
echo ""
read -p "Digite o nome do usuário a ser configurado: " TARGET_USER

# Validar entrada
if [ -z "$TARGET_USER" ]; then
    error "Nome de usuário não pode ser vazio"
    exit 1
fi

# --- Verificar se usuário existe
if ! id "$TARGET_USER" &>/dev/null; then
    error "Usuário '$TARGET_USER' não existe"
    echo "Crie primeiro com: sudo useradd -m -s /bin/bash $TARGET_USER"
    echo "                   sudo passwd $TARGET_USER"
    exit 1
fi

log "Configurando usuário: $TARGET_USER"
echo ""

# Documentação: https://wiki.archlinux.org/title/users_and_groups
GROUPS_TO_ADD=(
    "wheel"
    "video"
    "audio"
    "input"
    "storage"
    "network"
    "power"
    "rfkill"
    "seat"
    "docker"
)

# --- Adicionar usuário aos grupos
log "Adicionando $TARGET_USER aos grupos necessários..."
echo ""

for group in "${GROUPS_TO_ADD[@]}"; do
    # Verificar se o grupo existe
    if getent group "$group" > /dev/null 2>&1; then
        # Verificar se usuário já está no grupo
        if id -nG "$TARGET_USER" | grep -qw "$group"; then
            echo " -> $group: já membro ✓"
        else
            # Adicionar ao grupo
            if usermod -aG "$group" "$TARGET_USER"; then
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
log "Configurando sudo para $TARGET_USER..."

# Verificar se usuário está no grupo wheel
if ! id -nG "$TARGET_USER" | grep -qw "wheel"; then
    warn "Usuário não está no grupo 'wheel'. Adicionando..."
    usermod -aG wheel "$TARGET_USER"
fi

# Descomente apenas a linha para sudo com senha no /etc/sudoers
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
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
echo "  Usuário: $TARGET_USER"
echo "  Grupos: $(id -nG "$TARGET_USER" | tr ' ' ', ')"
echo "  Sudo: Com senha (descomentado em /etc/sudoers)"
echo ""
warn "IMPORTANTE: Faça logout e login novamente para aplicar as mudanças de grupo!"
echo ""
echo "Próximos passos:"
echo "  1. Abra um novo terminal (logout/login)"
echo "  2. Teste: sudo -v (pedirá senha)"
echo ""
echo "Recomendação de segurança:"
echo "  Para DESABILITAR acesso ao root sem sudo:"
echo "  Use: passwd -l root"
echo ""
