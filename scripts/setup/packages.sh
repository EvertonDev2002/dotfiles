#!/bin/bash
# scripts/setup/setup_packages.sh
# Instalação de Pacotes (Pacman + AUR)

# shellcheck source=./lib/bootstrap.sh
PATH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/lib/bootstrap.sh" 2>/dev/null; then
    # shellcheck disable=SC1091
    source "$PATH_BOOTSTRAP"
fi

# Definir SCRIPT_DIR corretamente
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${SCRIPT_DIR}/../../pkgs/yay/pkglist.txt"

# --- Contadores
installed=0
skipped=0
failed=0
failed_packages=""

# --- Instalação de Pacotes (Pacman + AUR)
if [ -f "$LIST_FILE" ]; then
    log "Lendo pkglist.txt e instalando pacotes..."

    # Contar total de pacotes
    total=$(grep -vE '^\s*#|^\s*$' "$LIST_FILE" | grep -c .)
    log "Total de pacotes a processar: $total"
    echo ""

    # Desabilitar exit on error durante a instalação
    set +e

    while IFS= read -r pkg; do
        # Pular linhas vazias e comentários
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue

        log "→ $pkg"

        # Verificar se já está instalado
        if yay -Qi "$pkg" &>/dev/null; then
            warn "  Já instalado"
            skipped=$((skipped + 1))
            continue
        fi

        # Tentar instalar
        if yay -S --needed --noconfirm "$pkg" &>/dev/null; then
            success "  Instalado"
            installed=$((installed + 1))
        else
            error "  Falha na instalação: $pkg"
            failed=$((failed + 1))
            failed_packages="${failed_packages:+$failed_packages, }$pkg"
        fi

    done <"$LIST_FILE"

    # Reabilitar exit on error
    set -e

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "Instalação de pacotes concluída!"
    echo "  ✓ Instalados: $installed"
    echo "  → Já existentes: $skipped"
    echo "  ✗ Falhados: $failed"
    if [ "$failed" -gt 0 ]; then
        echo "  ✗ Pacotes com falha: $failed_packages"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    warn "Arquivo pkglist.txt não encontrado. Pulando instalação de pacotes."
    exit 1
fi
