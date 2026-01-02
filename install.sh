#!/bin/bash
# install.sh - Script de Pós-instalação para Artix Linux (Runit + River)
# Autor: EvertonDev2002

# Variáveis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="${SCRIPT_DIR}/scripts/setup"
REPOS="${SETUP_DIR}/repos.sh"
YAY="${SETUP_DIR}/yay.sh"
PACKAGES="${SETUP_DIR}/packages.sh"
FLATPAK="${SETUP_DIR}/flatpaks.sh"
DOTFILES="${SETUP_DIR}/dotfiles.sh"
SERVICES="${SETUP_DIR}/services.sh"

# Carregar funções e cores comuns
source "${SCRIPT_DIR}/scripts/lib/common.sh"


log "Iniciando pós-instalação..."

chmod +x "${SETUP_DIR}/"*.sh
chmod +x "${SCRIPT_DIR}/scripts/tools/"*.sh

# --- Configuração de Repositórios (Arch Extra)
if [ -f "$REPOS" ]; then
    log "Executando setup de repositórios..."
    bash "$REPOS"
else
    error "Script scripts/setup/repos.sh não encontrado!"
    exit 1
fi

# --- Instalação do AUR Helper (Yay)
if [ -f "$YAY" ]; then
    log "Executando setup do Yay..."
    bash "$YAY"
else
    error "Script scripts/setup/yay.sh não encontrado!"
    exit 1
fi

# --- Instalação de Pacotes (Pacman + AUR)
if [ -f "$PACKAGES" ]; then
    log "Executando instalação de pacotes..."
    bash "$PACKAGES"
else
    error "Script scripts/setup/packages.sh não encontrado!"
    exit 1
fi

# --- Instalação de Flatpaks
if [ -f "$FLATPAK" ]; then
    log "Iniciando instalação de Flatpaks..."
    bash "$FLATPAK"
else
    warn "Script de Flatpaks não encontrado."
fi

# --- Arquivos de Sistema (Root)
if [ -f "${SETUP_DIR}/setup/system.sh" ]; then
    log "Deseja aplicar configurações de sistema em /etc? [y/N]"
    read -r sys_response
    if [[ "$sys_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        bash "${SETUP_DIR}/setup/system.sh"
    else
        warn "Configurações de sistema não aplicadas"
    fi
fi

# --- Habilitar Serviços Runit
if [ -f "$SERVICES" ]; then
    log "Executando setup de serviços Runit..."
    bash "$SERVICES"
else
    error "Script scripts/setup/services.sh não encontrado!"
    exit 1
fi

# --- Dotfiles (GNU Stow)
if [ -f "$DOTFILES" ]; then
    log "Executando setup de dotfiles..."
    bash "$DOTFILES"
else
    error "Script scripts/setup/dotfiles.sh não encontrado!"
    exit 1
fi

# --- Configuração do Firefox
if [ -f "${SETUP_DIR}/setup/firefox.sh" ]; then
    log "Deseja configurar Firefox (user.js e chrome/)? [Y/n]"
    read -r firefox_response
    if [[ "$firefox_response" =~ ^([nN][oO]|[nN])$ ]]; then
        warn "Configuração do Firefox ignorada"
    else
        bash "${SETUP_DIR}/setup/firefox.sh"
    fi
else
    warn "Script de configuração do Firefox não encontrado."
fi

# --- Verificar se root está ativo e perguntar se deseja desativar
log "Verificando status da conta root..."
if sudo passwd -S root | grep -q "Password locked"; then
    success "Conta root já está desativada"
else
    warn "Conta root está ativa"
    echo ""
    log "Deseja desativar a conta root (passwd -l root)? [y/N]"
    read -r root_response
    if [[ "$root_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if sudo passwd -l root; then
            success "Conta root desativada"
        else
            error "Falha ao desativar conta root"
        fi
    else
        warn "Conta root mantida ativa"
    fi
fi


echo ""
echo "========================================="
success "   INSTALAÇÃO CONCLUÍDA COM SUCESSO!     "
echo "========================================="
