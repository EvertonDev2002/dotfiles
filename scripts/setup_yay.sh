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
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

set -e

# --- Contadores
installed=0
skipped=0
failed=0

# --- Instalação do AUR Helper (Yay)
if ! command -v yay &> /dev/null; then
    log "Yay não encontrado. Instalando..."
    
    set +e
    if sudo pacman -S --needed --noconfirm git base-devel &> /dev/null; then
        success "Dependências instaladas"
    else
        error "Falha ao instalar dependências"
        failed=$((failed + 1))
        set -e
        exit 1
    fi
    set -e

    log "Clonando repositório do Yay..."
    set +e
    if git clone https://aur.archlinux.org/yay.git /tmp/yay &> /dev/null; then
        cd /tmp/yay
        if makepkg -si --noconfirm &> /dev/null; then
            success "Yay instalado!"
            installed=$((installed + 1))
        else
            error "Falha na compilação do Yay"
            failed=$((failed + 1))
            cd -
            rm -rf /tmp/yay
            set -e
            exit 1
        fi
        cd -
        rm -rf /tmp/yay
    else
        error "Falha ao clonar repositório"
        failed=$((failed + 1))
        set -e
        exit 1
    fi
    set -e
else
    success "Yay já instalado"
    skipped=$((skipped + 1))
fi

# Desabilitar exit on error para o resumo final
set +e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "Setup Yay concluído!"
echo "  ✓ Instalados: $installed"
echo "  → Já existentes: $skipped"
echo "  ✗ Falhados: $failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
