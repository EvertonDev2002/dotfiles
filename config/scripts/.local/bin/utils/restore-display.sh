#!/usr/bin/env bash
#
# restore-display.sh - Restaura layout padrão de displays (lado a lado)
# Uso: restore-display.sh [OUTPUT_NAME]
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

log_header "Restore Display - Layout Padrão"

# Auto-detectar monitor externo se não especificado
if [[ -z "$EXTERNAL_OUTPUT" ]]; then
  log_info "Detectando monitor externo..."

  # Lista outputs conectados (exclui o interno)
  OUTPUTS=$(niri msg -j outputs | jq -r '.[] | select(.name != "'"$INTERNAL_OUTPUT"'") | select(.connected == true) | .name')

  if [[ -z "$OUTPUTS" ]]; then
    log_warn "Nenhum monitor externo detectado"
    log_info "Apenas reposicionando monitor interno..."
    niri msg output "$INTERNAL_OUTPUT" position 0 0
    log_success "Monitor interno reposicionado"
    exit 0
  fi

  # Pega o primeiro output disponível
  EXTERNAL_OUTPUT=$(echo "$OUTPUTS" | head -n1)
  log_success "Monitor externo detectado: $EXTERNAL_OUTPUT"
fi

# Obter largura do monitor interno (principal) para posicionar externo
log_info "Obtendo informações do monitor interno..."
INTERNAL_WIDTH=$(niri msg -j outputs | jq -r '.[] | select(.name == "'"$INTERNAL_OUTPUT"'") | .current_mode.width')

if [[ -z "$INTERNAL_WIDTH" || "$INTERNAL_WIDTH" == "null" ]]; then
  log_warn "Não foi possível determinar largura do monitor interno"
  log_info "Usando largura padrão: 1920"
  INTERNAL_WIDTH=1920
else
  log_info "Largura do monitor interno: ${INTERNAL_WIDTH}px"
fi

# Restaura layout lado a lado (interno principal à esquerda)
log_info "Restaurando layout padrão..."

log_info "Posicionando $INTERNAL_OUTPUT (esquerda/principal)..."
niri msg output "$INTERNAL_OUTPUT" position 0 0

log_info "Posicionando $EXTERNAL_OUTPUT (direita)..."
niri msg output "$EXTERNAL_OUTPUT" position "$INTERNAL_WIDTH" 0

# Remove restrições de resolução (usa automático)
log_info "Restaurando resoluções automáticas..."
niri msg output "$EXTERNAL_OUTPUT" mode auto
niri msg output "$INTERNAL_OUTPUT" mode auto

log_separator
log_success "Layout restaurado!"
log_info "Monitor interno/principal ($INTERNAL_OUTPUT): posição (0, 0)"
log_info "Monitor externo ($EXTERNAL_OUTPUT): posição (${INTERNAL_WIDTH}, 0)"
log_separator
