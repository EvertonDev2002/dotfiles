#!/bin/bash
# setup_dotfiles.sh - Aplicação de Dotfiles com GNU Stow
# Autor: EvertonDev2002

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# --- Dotfiles (GNU Stow)
if command -v stow &> /dev/null; then
    log "Aplicando Dotfiles com Stow..."
    
    # Remove arquivos conflitantes do Fish se existirem
    [ -f "$HOME/.config/fish/config.fish" ] && rm -f "$HOME/.config/fish/config.fish"
    
    # Assumindo que o script está em dotfiles/scripts/
    DOTFILES_ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")" 
    cd "$DOTFILES_ROOT" || exit 1
    stow -d config -t "$HOME" -- * --verbose 2> /dev/null || warn "Alguns links já existem"
    success "Dotfiles linkados com sucesso!"
else
    error "GNU Stow não está instalado. Verifique o pkglist.txt"
    exit 1
fi
