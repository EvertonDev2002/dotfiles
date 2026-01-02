#!/usr/bin/env bash
#
# mirror-display.sh - Espelha tela do notebook em projetor/monitor externo
# Uso: mirror-display.sh [OUTPUT_NAME]
#

set -e

# Importa biblioteca de logging
# shellcheck source=../lib/logging.sh
# shellcheck disable=SC1091
source "${HOME}/.local/bin/lib/logging.sh"

# Nome do output interno (notebook)
INTERNAL_OUTPUT="eDP-1"

# Nome do output externo (auto-detectar ou usar argumento)
EXTERNAL_OUTPUT="${1:-}"

# Resolução para espelhamento (comum para apresentações)
MIRROR_RESOLUTION="1920x1080"

log_header "Mirror Display - Modo Apresentação"

# Auto-detectar monitor externo se não especificado
if [[ -z "$EXTERNAL_OUTPUT" ]]; then
  log_info "Detectando monitor externo..."

  # Lista outputs conectados (exclui o interno)
  OUTPUTS=$(niri msg -j outputs | jq -r '.[] | select(.name != "'"$INTERNAL_OUTPUT"'") | select(.connected == true) | .name')

  if [[ -z "$OUTPUTS" ]]; then
    log_error "Nenhum monitor externo detectado!"
    log_info "Conecte um projetor/monitor e tente novamente"
    exit 1
  fi

  # Pega o primeiro output disponível
  EXTERNAL_OUTPUT=$(echo "$OUTPUTS" | head -n1)
  log_success "Monitor externo detectado: $EXTERNAL_OUTPUT"
fi

# Configura ambos os outputs para mesma resolução
log_info "Configurando resolução de espelhamento: $MIRROR_RESOLUTION"

log_info "Configurando $INTERNAL_OUTPUT..."
niri msg output "$INTERNAL_OUTPUT" mode "$MIRROR_RESOLUTION"
niri msg output "$INTERNAL_OUTPUT" position 0 0

log_info "Configurando $EXTERNAL_OUTPUT..."
niri msg output "$EXTERNAL_OUTPUT" mode "$MIRROR_RESOLUTION"
niri msg output "$EXTERNAL_OUTPUT" position 0 0

log_separator
log_success "Modo espelhamento ativado!"
log_info "Tela do notebook: $INTERNAL_OUTPUT"
log_info "Projetor/Monitor: $EXTERNAL_OUTPUT"
log_info "Resolução: $MIRROR_RESOLUTION"
log_separator
echo ""
log_info "Para restaurar layout normal, execute: restore-display.sh"
