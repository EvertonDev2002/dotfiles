#!/bin/bash
# setup_yay.sh - Instalação do AUR Helper (Yay)
# Autor: EvertonDev2002

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

# --- Instalação do AUR Helper (Yay)
if ! command -v yay &> /dev/null; then
    log "Yay não encontrado. Instalando..."
    sudo pacman -S --needed --noconfirm git base-devel

    log "Clonando repositório do Yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay

    success "Yay instalado!"
else
    success "Yay já instalado"
fi
