#!/bin/bash
# install.sh - Script de Pós-instalação para Artix Linux (Runit + River)
# Autor: EvertonDev2002

# Variáveis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${SCRIPT_DIR}/pkgs/paru/pkglist.txt"
REPOS="${SCRIPT_DIR}/scripts/setup_repos.sh"
FLATPAK="${SCRIPT_DIR}/scripts/setup_flatpaks.sh"

# --- Cores e Formatação
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

set -e

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

# --- Instalação do AUR Helper (Paru)
if ! command -v paru &> /dev/null; then
    log "Paru não encontrado. Instalando..."
    sudo pacman -S --needed --noconfirm git base-devel

    log "Clonando repositório do Paru..."
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf /tmp/paru

    success "Paru instalado!"
else
    success "Paru já instalado"
fi

# --- Instalação de Pacotes (Pacman + AUR)
if [ -f "$LIST_FILE" ]; then
    log "Lendo pkglist.txt e instalando pacotes..."
    
    grep -vE '^\s*#|^\s*$' "$LIST_FILE" | paru -S --needed --noconfirm -
    
    success "Pacotes do sistema instalados."
else
    warn "Arquivo pkglist.txt não encontrado. Pulando instalação de pacotes."
fi

# --- Instalação de Flatpaks
if [ -f "$FLATPAK" ]; then
    log "Iniciando instalação de Flatpaks..."
    bash "$FLATPAK"
else
    warn "Script de Flatpaks não encontrado."
fi

# --- Ferramentas Adicionais (Opcional)
log "Deseja clonar o LinuxToys? (Scripts utilitários) [y/N]"
read -r -t 10 response || response="n" # Timeout de 10s assume "não"
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
   if [ ! -d "$HOME/linuxtoys" ]; then
       git clone https://github.com/psygreg/linuxtoys.git "$HOME/linuxtoys"
       success "LinuxToys clonado em ~/linuxtoys"
   else
       warn "LinuxToys já existe em ~/linuxtoys"
   fi
fi

# --- Dotfiles (GNU Stow)
if command -v stow &> /dev/null; then
    log "Aplicando Dotfiles com Stow..."
    
    # Remove arquivos conflitantes do Fish se existirem
    [ -f "$HOME/.config/fish/config.fish" ] && rm -f "$HOME/.config/fish/config.fish"
    
    cd "$SCRIPT_DIR"
    stow -d config -t "$HOME" -- * --verbose 2> /dev/null || warn "Alguns links já existem"
    success "Dotfiles linkados com sucesso!"
else
    error "GNU Stow não está instalado. Verifique o pkglist.txt"
fi

# --- Configuração do Firefox
if [ -f "${SCRIPT_DIR}/scripts/setup_firefox.sh" ]; then
    log "Deseja configurar Firefox (user.js e chrome/)? [Y/n]"
    read -r -t 10 firefox_response || firefox_response="y"
    if [[ "$firefox_response" =~ ^([nN][oO]|[nN])$ ]]; then
        warn "Configuração do Firefox ignorada"
    else
        bash "${SCRIPT_DIR}/scripts/setup_firefox.sh"
    fi
fi

# --- Arquivos de Sistema (Root)
if [ -f "${SCRIPT_DIR}/scripts/setup_system.sh" ]; then
    log "Deseja aplicar configurações de sistema em /etc? [y/N]"
    read -r -t 10 sys_response || sys_response="n"
    if [[ "$sys_response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        bash "${SCRIPT_DIR}/scripts/setup_system.sh"
    else
        warn "Configurações de sistema não aplicadas"
    fi
fi

# --- Habilitar Serviços Runit
log "Configurando serviços do Runit..."

enable_service() {
    local service="$1"
    if [ -d "/etc/runit/sv/$service" ]; then
        if [ ! -L "/etc/runit/runsvdir/default/$service" ]; then
            log "Habilitando serviço: $service"
            sudo ln -s "/etc/runit/sv/$service" "/etc/runit/runsvdir/default"
        else
            echo " -> $service já está ativo."
        fi
    else
        warn "Serviço '$service' não encontrado em /etc/runit/sv. O pacote foi instalado?"
    fi
}

# Lista de serviços 
enable_service "ly"
enable_service "NetworkManager"
enable_service "bluetoothd"
enable_service "docker"
enable_service "tlp" 
enable_service "ufw"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   INSTALAÇÃO CONCLUÍDA COM SUCESSO!     ${NC}"
echo -e "${GREEN}=========================================${NC}"