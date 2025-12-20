#!/bin/bash
# install.sh - Script de Pós-instalação para Artix Linux (Runit + River)
# Autor: EvertonDev2002

# Variáveis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS="${SCRIPT_DIR}/scripts/setup_repos.sh"
YAY="${SCRIPT_DIR}/scripts/setup_yay.sh"
PACKAGES="${SCRIPT_DIR}/scripts/setup_packages.sh"
FLATPAK="${SCRIPT_DIR}/scripts/setup_flatpaks.sh"
DOTFILES="${SCRIPT_DIR}/scripts/setup_dotfiles.sh"
SERVICES="${SCRIPT_DIR}/scripts/setup_services.sh"

# Carregar funções e cores comuns
source "${SCRIPT_DIR}/scripts/lib/common.sh"


log "Iniciando pós-instalação..."

chmod +x "${SCRIPT_DIR}/scripts/"*.sh

# --- Configuração de Repositórios (Arch Extra)
if [ -f "$REPOS" ]; then
    log "Executando setup de repositórios..."
    bash "$REPOS"
else
    error "Script scripts/setup_repos.sh não encontrado!"
    exit 1
fi

# --- Instalação do AUR Helper (Yay)
if [ -f "$YAY" ]; then
    log "Executando setup do Yay..."
    bash "$YAY"
else
    error "Script scripts/setup_yay.sh não encontrado!"
    exit 1
fi

# --- Instalação de Pacotes (Pacman + AUR)
if [ -f "$PACKAGES" ]; then
    log "Executando instalação de pacotes..."
    bash "$PACKAGES"
else
    error "Script scripts/setup_packages.sh não encontrado!"
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
if [ -f "${SCRIPT_DIR}/scripts/setup_system.sh" ]; then
    log "Deseja aplicar configurações de sistema em /etc? [y/N]"
    read -r sys_response
    if [[ "$sys_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        bash "${SCRIPT_DIR}/scripts/setup_system.sh"
    else
        warn "Configurações de sistema não aplicadas"
    fi
fi

# --- Habilitar Serviços Runit
if [ -f "$SERVICES" ]; then
    log "Executando setup de serviços Runit..."
    bash "$SERVICES"
else
    error "Script scripts/setup_services.sh não encontrado!"
    exit 1
fi

# --- Dotfiles (GNU Stow)
if [ -f "$DOTFILES" ]; then
    log "Executando setup de dotfiles..."
    bash "$DOTFILES"
else
    error "Script scripts/setup_dotfiles.sh não encontrado!"
    exit 1
fi

# --- Configuração do Firefox
if [ -f "${SCRIPT_DIR}/scripts/setup_firefox.sh" ]; then
    log "Deseja configurar Firefox (user.js e chrome/)? [Y/n]"
    read -r firefox_response
    if [[ "$firefox_response" =~ ^([nN][oO]|[nN])$ ]]; then
        warn "Configuração do Firefox ignorada"
    else
        bash "${SCRIPT_DIR}/scripts/setup_firefox.sh"
    fi
else
    warn "Script de configuração do Firefox não encontrado."
fi

# --- Ferramentas Adicionais (Opcional)
# log "Deseja clonar o LinuxToys? (Scripts utilitários) [y/N]"
# read -r -t 10 response || response="n" # Timeout de 10s assume "não"
# if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
#    if [ ! -d "$HOME/linuxtoys" ]; then
#        git clone https://github.com/psygreg/linuxtoys.git "$HOME/linuxtoys"
#        success "LinuxToys clonado em ~/linuxtoys"
#    else
#        warn "LinuxToys já existe em ~/linuxtoys"
#    fi
# fi

echo ""
echo "========================================="
success "   INSTALAÇÃO CONCLUÍDA COM SUCESSO!     "
echo "========================================="
