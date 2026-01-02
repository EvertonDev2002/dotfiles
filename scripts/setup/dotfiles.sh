#!/usr/bin/env bash
# scripts/setup/dotfiles.sh
# Aplicação de Dotfiles com GNU Stow
# Autor: EvertonDev2002

# Carrega bootstrap para variáveis e funções comuns
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH_BOOTSTRAP="$SCRIPT_DIR/../lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$PATH_BOOTSTRAP" 2>/dev/null; then
    echo "Arquivo bootstrap não encontrado: $PATH_BOOTSTRAP" >&2
    exit 1
fi

# Valida pré-requisitos
if ! command -v stow &>/dev/null; then
    error "GNU Stow não está instalado. Verifique o pkglist.txt"
    exit 1
fi

log "Aplicando Dotfiles com Stow..."

# Backup de arquivos conflitantes comuns
backup_timestamp=$(date +%s)
for config_dir in "$HOME/.config/fish" "$HOME/.config/river" "$HOME/.config/waybar"; do
    if [[ -d "$config_dir" && ! -L "$config_dir" ]]; then
        backup_dir="${config_dir}.bak.${backup_timestamp}"
        mv "$config_dir" "$backup_dir"
        log "Backup criado: $backup_dir"
    fi
done

# Aplica dotfiles
cd "$DOTFILES_DIR/config" || exit 1
log "Diretório atual: $(pwd)"
log "Prévia dos diretórios a serem linkados:"
# shellcheck disable=SC2035
ls -1d */

# Expansão de glob: passa todos os diretórios para o stow
# shellcheck disable=SC2035
if stow -t "$HOME" -v --adopt */ 2>&1; then
    success "Dotfiles linkados com sucesso!"
    # Verifica alguns links criados
    log "Verificando links criados:"
    [[ -L "$HOME/.config/fish" ]] && echo "  ✓ Fish configurado"
    [[ -L "$HOME/.config/river" ]] && echo "  ✓ River configurado"
    [[ -L "$HOME/.config/waybar" ]] && echo "  ✓ Waybar configurado"
    [[ -L "$HOME/.config/kitty" ]] && echo "  ✓ Kitty configurado"
else
    error "Falha ao aplicar dotfiles. Verifique conflitos:"
    warn "Execute: cd $DOTFILES_DIR/config && stow -n -v --adopt */"
    exit 1
fi