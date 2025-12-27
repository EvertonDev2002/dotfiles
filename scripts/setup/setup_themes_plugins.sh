#!/bin/bash
#  Instala Colloid e cria links para todos os temas/ícones

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

IFS=$'\n\t'

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
readonly TEMP_DIR="/tmp/setup-${SCRIPT_NAME%.*}-$$"
readonly COLLOID_REPO="https://github.com/vinceliuice/Colloid-gtk-theme"

# --- Diretórios de destino
readonly THEMES_XDG="$HOME/.local/share/themes"
readonly ICONS_XDG="$HOME/.local/share/icons"
readonly THEMES_LEGACY="$HOME/.themes"
readonly ICONS_LEGACY="$HOME/.icons"

cleanup() {
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

check_dependencies() {
    log "Verificando dependências do sistema..."
    
    local -a missing=()
    local -a deps=("git" "curl" "sassc" "fish")
    
    if ! pacman -Qi "gtk-engine-murrine" &> /dev/null; then
        missing+=("gtk-engine-murrine")
    fi
    if ! pacman -Qi "gnome-themes-extra" &> /dev/null; then
        missing+=("gnome-themes-extra")
    fi
    

    for pkg in "${deps[@]}"; do
        if ! command -v "$pkg" &> /dev/null && ! pacman -Qi "$pkg" &> /dev/null; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Dependências faltando: ${missing[*]}"
        log "Deseja instalar? [Y/n]"
        read -r -t 30 response || response="y"
        
        if [[ "$response" =~ ^([yY]|)$ ]]; then
            sudo pacman -S --noconfirm --needed "${missing[@]}"
            success "Dependências instaladas"
        else
            error "Dependências não instaladas. Abortando."
            return 1
        fi
    else
        success "Todas as dependências presentes"
    fi
}

install_colloid() {
    log "Instalando Colloid GTK Theme..."
    
    mkdir -p "$TEMP_DIR"
    
    if ! git clone --depth 1 "$COLLOID_REPO" "$TEMP_DIR/Colloid-gtk-theme"; then
        error "Falha ao clonar repositório Colloid"
        return 1
    fi
    
    cd "$TEMP_DIR/Colloid-gtk-theme" || return 1
    chmod +x install.sh
    
    log "Compilando variante dark com tweaks rimless..."
    if sudo ./install.sh -c dark --tweaks rimless -l && sudo ./install.sh -c dark --tweaks rimless; then
        success "Colloid instalado com sucesso"
        cd - > /dev/null || return 1
        return 0
    else
        error "Falha ao instalar Colloid"
        cd - > /dev/null || return 1
        return 1
    fi
}

create_directories() {
    log "Criando estrutura de diretórios..."
    
    mkdir -p "$THEMES_XDG" "$ICONS_XDG" "$THEMES_LEGACY" "$ICONS_LEGACY"
    
    success "Diretórios criados:"
    echo "  • $THEMES_XDG"
    echo "  • $ICONS_XDG"
    echo "  • $THEMES_LEGACY"
    echo "  • $ICONS_LEGACY"
}

link_items() {
    local src_base="$1"
    local dst_base="$2"
    local label="$3"
    
    [ ! -d "$src_base" ] && { warn "$src_base não encontrado"; return 1; }
    
    log "Criando links: $label"
    
    local -i linked=0 skipped=0
    
    # Encontrar todos os diretórios, exceto os padrão
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        
        local src="$src_base/$item"
        local dst="$dst_base/$item"
        
        # Pular se já existe link
        if [ -L "$dst" ]; then
            ((skipped++))
            continue
        fi
        
        # Avisar se há pasta real (não sobrescrever)
        if [ -e "$dst" ]; then
            warn "  ! $item já existe (não é link). Pulando."
            ((skipped++))
            continue
        fi
        
        # Criar link
        if ln -s "$src" "$dst" 2>/dev/null; then
            ((linked++))
        else
            error "  Falha ao linkar $item"
        fi
        
    done < <(find "$src_base" -maxdepth 1 -type d \
        ! -name "default" ! -name "hicolor" ! -name "HighContrast" \
        -printf "%f\n" | sort)
    
    success "$label: $linked links criados, $skipped pulados"
}

create_symlinks() {
    log "Gerando links simbólicos..."
    echo ""
    
    create_directories
    echo ""
    
    # Temas
    if [ -d "/usr/share/themes" ]; then
        link_items "/usr/share/themes" "$THEMES_XDG" "Temas (XDG Standard)"
        link_items "/usr/share/themes" "$THEMES_LEGACY" "Temas (Legacy)"
    else
        warn "/usr/share/themes não encontrado"
    fi
    
    echo ""
    
    # Ícones
    if [ -d "/usr/share/icons" ]; then
        link_items "/usr/share/icons" "$ICONS_XDG" "Ícones (XDG Standard)"
        link_items "/usr/share/icons" "$ICONS_LEGACY" "Ícones (Legacy)"
    else
        warn "/usr/share/icons não encontrado"
    fi
}



install_fish_plugins() {
    log "Instalando plugins do Fish..."
    
    if ! command -v fish &> /dev/null; then
        error "Fish shell não está instalado"
        return 1
    fi
    
    if ! pacman -Qs "fisher" | grep -w "fisher" &> /dev/null; then
        error "Fisher não está instalado. Instale via: pacman -S fisher"
        return 1
    fi
    
    fish << 'EOF'
# Instalar plugins
fisher install jorgebucaran/autopair.fish 2>/dev/null || true
fisher install meaningful-oasis/sponge 2>/dev/null || true
fisher install PatrickF1/fzf.fish 2>/dev/null || true
fisher install oh-my-fish/plugin-sudope 2>/dev/null || true
EOF
    
    success "Plugins instalados"
}

install_pnpm() {
    log "Instalando pnpm (gestor de pacotes Node.js)..."
    
    if command -v pnpm &> /dev/null; then
        success "pnpm já está instalado"
        return 0
    fi
    
    if curl -fsSL https://get.pnpm.io/install.sh | sh -; then
        success "pnpm instalado com sucesso"
        
        # Atualizar PATH para a sessão atual
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME:$PATH"
        
        log "pnpm versão: $(pnpm --version)"
        return 0
    else
        error "Falha ao instalar pnpm"
        return 1
    fi
}

show_menu() {
    echo ""
    echo "  1) Instalar tudo (Colloid + Plugins Fish + Links + pnpm)"
    echo "  2) Apenas Colloid GTK"
    echo "  3) Apenas Plugins Fish (Fisher)"
    echo "  4) Apenas Links Simbólicos"
    echo "  5) Apenas pnpm (Gestor de pacotes Node)"
    echo "  6) Apenas Dependências"
    echo "  7) Sair"
    echo ""
    read -p "Escolha [1-7]: " choice
}

main() {
    while true; do
        show_menu
        
        case "$choice" in
            1)
                check_dependencies && \
                install_colloid && \
                create_symlinks && \
                install_fish_plugins && \
                install_pnpm && \
                success "Setup completo finalizado!"
                ;;
            2)
                check_dependencies && install_colloid
                ;;
            3)
                check_dependencies && install_fish_plugins
                ;;
            4)
                create_symlinks
                ;;
            5)
                check_dependencies && install_pnpm
                ;;
            6)
                check_dependencies
                ;;
            7)
                log "Saindo..."
                exit 0
                ;;
            *)
                error "Opção inválida"
                ;;
        esac
        
        echo ""
        read -p "Pressione Enter para continuar..."
    done
}
main "$@"