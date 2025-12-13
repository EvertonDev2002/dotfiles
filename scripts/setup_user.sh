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

# --- Grupos necessários para desktop/desenvolvimento
# Documentação: https://wiki.archlinux.org/title/users_and_groups
GROUPS_TO_ADD=(
    "wheel"        # Sudo/administração
    "video"        # Acesso a dispositivos de vídeo (GPU)
    "audio"        # Acesso a dispositivos de áudio
    "input"        # Acesso a dispositivos de input (teclado, mouse)
    "storage"      # Acesso a dispositivos de armazenamento removíveis
    "optical"      # Acesso a drives ópticos (CD/DVD)
    "lp"           # Acesso a impressoras
    "scanner"      # Acesso a scanners
    "network"      # Gerenciamento de rede (NetworkManager)
    "power"        # Gerenciamento de energia (suspend, hibernate)
    "rfkill"       # Controle de dispositivos wireless
    "users"        # Grupo padrão de usuários
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
SUDOERS_FILE="/etc/sudoers.d/10-$REAL_USER"

log "Configurando sudo para $REAL_USER..."

# Verificar se usuário está no grupo wheel
if ! id -nG "$REAL_USER" | grep -qw "wheel"; then
    warn "Usuário não está no grupo 'wheel'. Adicionando..."
    usermod -aG wheel "$REAL_USER"
fi

# Criar arquivo sudoers específico do usuário
if [ -f "$SUDOERS_FILE" ]; then
    warn "Arquivo $SUDOERS_FILE já existe. Sobrescrevendo..."
fi

# Criar arquivo com permissões corretas ANTES de escrever
touch "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"

# Escrever configuração (sudo sem senha)
cat > "$SUDOERS_FILE" << EOF
# Configuração de sudo para $REAL_USER
# Criado automaticamente por setup_user.sh

# Permitir sudo sem senha
$REAL_USER ALL=(ALL:ALL) NOPASSWD: ALL

# Preservar variáveis de ambiente úteis
Defaults:$REAL_USER env_keep += "HOME"
Defaults:$REAL_USER env_keep += "XDG_RUNTIME_DIR"
Defaults:$REAL_USER env_keep += "DISPLAY"
Defaults:$REAL_USER env_keep += "WAYLAND_DISPLAY"
EOF

# Validar sintaxe do sudoers
if visudo -c -f "$SUDOERS_FILE" > /dev/null 2>&1; then
    success "Arquivo sudoers criado: $SUDOERS_FILE"
else
    error "Erro na sintaxe do sudoers! Removendo arquivo..."
    rm -f "$SUDOERS_FILE"
    exit 1
fi

# Garantir que /etc/sudoers inclui arquivos .d/
if ! grep -q "^#includedir /etc/sudoers.d" /etc/sudoers; then
    warn "Adicionando #includedir ao /etc/sudoers..."
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers
fi

echo ""
success "Configuração concluída!"
echo ""
echo "Detalhes:"
echo "  Usuário: $REAL_USER"
echo "  Grupos: $(id -nG "$REAL_USER" | tr ' ' ', ')"
echo "  Sudoers: $SUDOERS_FILE"
echo ""
warn "IMPORTANTE: Faça logout e login novamente para aplicar as mudanças de grupo!"
echo ""
echo "Para testar sudo:"
echo "  1. Abra um novo terminal (logout/login)"
echo "  2. Execute: sudo -v"
echo "  3. Não deve pedir senha"
