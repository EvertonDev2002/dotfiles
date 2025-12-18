#!/bin/bash
set -eo pipefail

# --- Variáveis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${SCRIPT_DIR}/../pkgs/flatpak/flatpaklist.txt"

# --- Cores
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

install_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        log "Instalando pacote flatpak..."
        sudo pacman -S --needed --noconfirm flatpak
        success "Flatpak instalado"
    else
        success "Flatpak já instalado"
    fi
}

setup_flathub() {
    if ! flatpak remotes | grep -q "flathub"; then
        log "Adicionando repositório Flathub..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        success "Flathub adicionado"
    else
        success "Flathub já configurado"
    fi
}

install_apps() {
    [ ! -f "$LIST_FILE" ] && { error "Arquivo $LIST_FILE não encontrado!"; exit 1; }
    
    log "Instalando aplicativos do Flathub..."
    echo ""
    
    local installed=0 skipped=0 failed=0
    
    # Desabilitar exit on error temporariamente
    set +e
    
    while IFS= read -r app_id; do
        # Pular linhas vazias
        [ -z "$app_id" ] && continue
        
        log "→ $app_id"
        
        # Verificar se já está instalado
        if flatpak list --app --columns=application | grep -qx "$app_id"; then
            warn "  Já instalado"
            ((skipped++))
            continue
        fi
        
        # Tentar instalar
        if flatpak install -y flathub "$app_id" &> /dev/null; then
            success "  Instalado"
            ((installed++))
        else
            error "  Falha na instalação"
            ((failed++))
        fi
        
    done < "$LIST_FILE"
    
    # Reabilitar exit on error
    set -e
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "Instalação concluída!"
    echo "  Instalados: $installed"
    echo "  Já existentes: $skipped"
    echo "  Falhados: $failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

setup_themes() {
    log "Aplicando permissões de tema para Flatpaks..."
    
    sudo flatpak override --filesystem="$HOME/.themes" &> /dev/null
    sudo flatpak override --filesystem="$HOME/.icons" &> /dev/null
    sudo flatpak override --filesystem=xdg-config/gtk-3.0 &> /dev/null
    sudo flatpak override --filesystem=xdg-config/gtk-4.0 &> /dev/null
    
    success "Permissões de tema configuradas"
}

main() {
    install_flatpak
    setup_flathub
    echo ""
    install_apps
    echo ""
    setup_themes
    
    echo ""
    success "Setup de Flatpaks finalizado!"
    echo ""
}

main "$@"