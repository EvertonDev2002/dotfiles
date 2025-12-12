#!/bin/bash
# scripts/setup_flatpaks.sh

set -euo pipefail

# Variáveis
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${SCRIPT_DIR}/../pkgs/flatpak/flatpaklist.txt"

# --- Cores e Formatação
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

log "Configurando Flatpaks..."

# --- Instalar Flatpak
if ! command -v flatpak &> /dev/null; then
    log "Instalando pacote flatpak..."
    sudo pacman -S --needed --noconfirm flatpak
    success "Flatpak instalado"
else
    success "Flatpak já instalado"
fi

# --- Adicionar repositório Flathub
if ! flatpak remotes | grep -q "flathub"; then
    log "Adicionando repositório Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub adicionado"
else
    success "Flathub já configurado"
fi

# --- Instalar Apps
if [ -f "$LIST_FILE" ]; then
    log "Lendo $LIST_FILE e instalando aplicativos..."
    
    while IFS= read -r app; do
        if [ -n "$app" ]; then
            log " -> Instalando: $app"
            if flatpak install -y flathub "$app" 2>/dev/null; then
                success "$app instalado"
            else
                warn "Falha ou já instalado: $app"
            fi
        fi
    done < <(grep -vE '^\s*#|^\s*$' "$LIST_FILE")
    
    success "Instalação de aplicativos concluída"
else
    error "Arquivo $LIST_FILE não encontrado!"
    exit 1
fi

# --- Configuração de Temas (Integração com Sistema)
log "Aplicando overrides globais de tema..."
sudo flatpak override --filesystem="$HOME"/.themes
sudo flatpak override --filesystem="$HOME"/.icons
sudo flatpak override --filesystem=xdg-config/gtk-3.0
sudo flatpak override --filesystem=xdg-config/gtk-4.0

success "Instalação de Flatpaks concluída."