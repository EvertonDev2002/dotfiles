#!/bin/bash
# setup_yay.sh - Instalação do AUR Helper (Yay)
# Autor: EvertonDev2002

# Carregar funções e cores comuns
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

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
