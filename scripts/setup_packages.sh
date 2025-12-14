#!/bin/bash
# setup_packages.sh - Instalação de Pacotes (Pacman + AUR)
# Autor: EvertonDev2002

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${SCRIPT_DIR}/../pkgs/yay/pkglist.txt"

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

# --- Instalação de Pacotes (Pacman + AUR)
if [ -f "$LIST_FILE" ]; then
    log "Lendo pkglist.txt e instalando pacotes..."
    
    grep -vE '^\s*#|^\s*$' "$LIST_FILE" | yay -S --needed --noconfirm -
    
    success "Pacotes do sistema instalados."
else
    warn "Arquivo pkglist.txt não encontrado. Pulando instalação de pacotes."
fi
