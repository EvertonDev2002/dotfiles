#!/bin/bash
# ============================================================================
#  SETUP THEMES & ICONS
#  Copia temas e ícones de /usr/share para ~/.local/share (user-level)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error() { echo -e "${RED}[ERRO]${NC} $1"; }

# --- Diretórios
SYSTEM_THEMES="/usr/share/themes"
SYSTEM_ICONS="/usr/share/icons"
USER_THEMES="$HOME/.local/share/themes"
USER_ICONS="$HOME/.local/share/icons"

# Criar diretórios de destino
mkdir -p "$USER_THEMES" "$USER_ICONS"

copy_items() {
    local source_dir="$1"
    local dest_dir="$2"
    local item_type="$3"
    
    if [ ! -d "$source_dir" ]; then
        log_warn "Diretório $source_dir não encontrado. Pulando..."
        return
    fi
    
    log_info "Procurando $item_type em $source_dir..."
    
    # Listar itens disponíveis (excluir Adwaita e default que são padrão)
    local items=$(find "$source_dir" -maxdepth 1 -type d ! -name "Adwaita*" ! -name "default" ! -name "hicolor" -printf "%f\n" | grep -v "^themes$\|^icons$" | sort)
    
    if [ -z "$items" ]; then
        log_warn "Nenhum $item_type customizado encontrado."
        return
    fi
    
    echo ""
    log_info "$item_type disponíveis:"
    echo "$items" | nl -w2 -s'. '
    echo ""
    
    read -p "Copiar todos os $item_type? [S/n] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        read -p "Digite os números dos itens para copiar (ex: 1 3 5) ou 'todos': " selection
        
        if [[ "$selection" == "todos" ]]; then
            selection=""
        fi
    else
        selection=""
    fi
    
    local copied=0
    local skipped=0
    
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        
        local should_copy=true
        
        # Verificar se deve copiar baseado na seleção
        if [ -n "$selection" ]; then
            should_copy=false
            local index=1
            while IFS= read -r candidate; do
                if echo "$selection" | grep -qw "$index"; then
                    if [ "$candidate" = "$item" ]; then
                        should_copy=true
                        break
                    fi
                fi
                ((index++))
            done <<< "$items"
        fi
        
        if [ "$should_copy" = true ]; then
            local source_path="$source_dir/$item"
            local dest_path="$dest_dir/$item"
            
            if [ -e "$dest_path" ]; then
                log_warn "$item já existe em $dest_dir. Pulando..."
                ((skipped++))
                continue
            fi
            
            log_info "Copiando $item..."
            if cp -r "$source_path" "$dest_path" 2>/dev/null; then
                log_success "$item copiado com sucesso"
                ((copied++))
            else
                log_error "Falha ao copiar $item"
            fi
        fi
    done <<< "$items"
    
    echo ""
    log_success "$item_type: $copied copiados, $skipped ignorados"
}

# --- Main
echo "============================================================================"
echo "  COPIAR TEMAS E ÍCONES DO SISTEMA PARA USUÁRIO"
echo "============================================================================"
echo ""

log_info "Destinos:"
log_info "  Temas → $USER_THEMES"
log_info "  Ícones → $USER_ICONS"
echo ""

# Copiar temas
copy_items "$SYSTEM_THEMES" "$USER_THEMES" "temas"
echo ""

# Copiar ícones
copy_items "$SYSTEM_ICONS" "$USER_ICONS" "ícones"
echo ""

log_success "Configuração de temas e ícones concluída!"
log_info "Os temas/ícones agora estão disponíveis no nível do usuário."
echo ""
log_info "Comandos úteis:"
echo "  • Listar temas: ls ~/.local/share/themes"
echo "  • Listar ícones: ls ~/.local/share/icons"
echo "  • Aplicar tema GTK: gsettings set org.gnome.desktop.interface gtk-theme 'NomeDoTema'"
echo "  • Aplicar ícones: gsettings set org.gnome.desktop.interface icon-theme 'NomeDosIcones'"
