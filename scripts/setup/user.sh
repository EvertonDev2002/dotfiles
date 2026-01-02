#!/bin/bash
#  SETUP USER - Configura sudo e grupos do usuário

# shellcheck source=./lib/bootstrap.sh
PATH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/lib/bootstrap.sh" 2>/dev/null; then
    # shellcheck disable=SC1091
    source "$PATH_BOOTSTRAP"
fi

# --- Pedir sudo se necessário
if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

# --- Verificar e instalar Docker se necessário
if ! command -v docker &>/dev/null; then
    log "Docker não está instalado. Instalando..."
    if yay -S --needed --noconfirm docker; then
        success "Docker instalado"
    else
        error "Falha ao instalar Docker"
        exit 1
    fi
else
    success "Docker já instalado"
fi

# --- Verificar e instalar Fish se necessário
if ! command -v fish &>/dev/null; then
    log "Fish não está instalado. Instalando..."
    if yay -S --needed --noconfirm fish; then
        success "Fish instalado"
    else
        error "Falha ao instalar Fish"
        exit 1
    fi
else
    success "Fish já instalado"
fi

# --- Pedir nome do usuário
echo ""
read -r -p "Digite o nome do usuário a ser configurado: " TARGET_USER

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
    'wheel'
    'video'
    'audio'
    'tty'
    'input'
    'storage'
    'network'
    'power'
    'rfkill'
    'seat'
    'docker'
)

# --- Adicionar usuário aos grupos
log "Adicionando $TARGET_USER aos grupos necessários..."
echo ""

for group in "${GROUPS_TO_ADD[@]}"; do
    # Verificar se o grupo existe
    if getent group "$group" >/dev/null 2>&1; then
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

    if visudo -c >/dev/null 2>&1; then
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


# --- Definir shell padrão para fish
log "Definindo shell padrão para fish para $TARGET_USER e root..."

if command -v fish >/dev/null 2>&1; then
    if chsh -s /usr/bin/fish "$TARGET_USER"; then
        success "Shell padrão do $TARGET_USER alterado para fish"
    else
        warn "Falha ao alterar shell do $TARGET_USER"
    fi

    if sudo chsh -s /usr/bin/fish root; then
        success "Shell padrão do root alterado para fish"
    else
        warn "Falha ao alterar shell do root"
    fi
else
    warn "Fish shell não está instalado. Pule a configuração do shell."
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
