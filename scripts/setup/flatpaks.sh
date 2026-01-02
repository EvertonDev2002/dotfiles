#!/bin/bash
# scripts/setup/setup_flatpaks.sh

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
LIST_FILE="${SCRIPT_DIR}/../../pkgs/flatpak/flatpaklist.txt"

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
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
    [ ! -f "$LIST_FILE" ] && {
        error "Arquivo $LIST_FILE não encontrado!"
        exit 1
    }

    log "Instalando aplicativos do Flathub..."
    echo ""

    local installed=0 skipped=0 failed=0
    local failed_apps=""

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
        if flatpak install -y flathub "$app_id" &>/dev/null; then
            success "  Instalado"
            ((installed++))
        else
            error "  Falha na instalação: $app_id"
            ((failed++))
            failed_apps="${failed_apps:+$failed_apps, }$app_id"
        fi

    done <"$LIST_FILE"

    # Reabilitar exit on error
    set -e

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    success "Instalação concluída!"
    echo "  ✓ Instalados: $installed"
    echo "  → Já existentes: $skipped"
    echo "  ✗ Falhados: $failed"
    if [ "$failed" -gt 0 ]; then
        echo "  ✗ Apps com falha: $failed_apps"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

setup_themes() {
    log "Aplicando permissões de tema e compatibilidade para Flatpaks..."

    sudo flatpak override --filesystem=xdg-config/gtk-3.0 &>/dev/null
    sudo flatpak override --filesystem=xdg-config/gtk-4.0 &>/dev/null
    sudo flatpak override --filesystem="$HOME/.local/share/icons"
    sudo flatpak override --filesystem="$HOME/.local/share/themes"
    sudo flatpak override --filesystem="$HOME/.config/dconf:ro"
    sudo flatpak override --filesystem="xdg-config/gtk-3.0:ro"
    sudo flatpak override --filesystem="xdg-config/gtk-4.0:ro"
    sudo flatpak override --filesystem="$HOME/.themes"
    sudo flatpak override --filesystem="$HOME/.icons"
    sudo flatpak override --filesystem="xdg-config/Kvantum:ro"
    sudo flatpak override --env=QT_STYLE_OVERRIDE=kvantum
    sudo flatpak override --env=GTK_DECORATION_LAYOUT=''
    sudo flatpak override --env=XCURSOR_THEME=Bibata-Modern-Ice
    sudo flatpak override --env=GTK_THEME=Colloid-Dark
    sudo flatpak override --talk-name=ca.desrt.dconf

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
