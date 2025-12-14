#!/bin/bash
# setup_dotfiles.sh - Aplicação de Dotfiles com GNU Stow
# Autor: EvertonDev2002

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# --- Dotfiles (GNU Stow)
if command -v stow &> /dev/null; then
    log "Aplicando Dotfiles com Stow..."
    
    # Remove arquivos conflitantes do Fish se existirem
    [ -f "$HOME/.config/fish/config.fish" ] && rm -f "$HOME/.config/fish/config.fish"
    
    cd "${SCRIPT_DIR}/.."
    stow -d config -t "$HOME" -- * --verbose 2> /dev/null || warn "Alguns links já existem"
    success "Dotfiles linkados com sucesso!"
else
    error "GNU Stow não está instalado. Verifique o pkglist.txt"
    exit 1
fi
