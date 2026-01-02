#!/usr/bin/env bash
# Script para concatenar módulos KDL em config.kdl
# Uso: ./build-config.sh

# Não usar set -e para evitar paradas inesperadas
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
OUTPUT_FILE="$SCRIPT_DIR/config.kdl"
BACKUP_FILE="$SCRIPT_DIR/config.kdl._bak"

# Importa biblioteca de logging
# shellcheck source=../../../scripts/.local/bin/lib/logging.sh
source "${HOME}/.local/bin/lib/logging.sh"

# Verifica se diretório de módulos existe
if [[ ! -d "$MODULES_DIR" ]]; then
  log_error "Diretório de módulos não encontrado: $MODULES_DIR"
  exit 1
fi

# Faz backup do config.kdl atual se existir
if [[ -f "$OUTPUT_FILE" ]]; then
  log_info "Fazendo backup de $OUTPUT_FILE para $BACKUP_FILE"
  cp "$OUTPUT_FILE" "$BACKUP_FILE"
fi

# Cria cabeçalho de aviso
log_info "Gerando $OUTPUT_FILE a partir dos módulos..."

{
  echo "// ============================================================================="
  echo "// ATENÇÃO: Este arquivo foi gerado automaticamente por build-config.sh"
  echo "// NÃO edite este arquivo diretamente!"
  echo "//"
  echo "// Para fazer mudanças, edite os arquivos em modules/ e execute:"
  echo "//   ./build-config.sh"
  echo "// ============================================================================="
  echo ""
} >"$OUTPUT_FILE"

# Concatena todos os módulos em ordem
module_count=0
for module in "$MODULES_DIR"/*.kdl; do
  if [[ -f "$module" ]]; then
    module_name=$(basename "$module")
    log_info "Adicionando módulo: $module_name"

    {
      echo ""
      echo "// ===== Módulo: $module_name ====="
      echo ""
      cat "$module"
    } >>"$OUTPUT_FILE"

    ((module_count++))
  fi
done

if [[ $module_count -eq 0 ]]; then
  log_error "Nenhum módulo encontrado em $MODULES_DIR"
  exit 1
fi

log_info "Configuração gerada com sucesso!"
log_info "Total de módulos concatenados: $module_count"
log_info "Arquivo gerado: $OUTPUT_FILE"

# Valida sintaxe se niri estiver disponível
if command -v niri &>/dev/null; then
  log_info "Validando configuração com 'niri validate'..."
  if niri validate -c "$OUTPUT_FILE"; then
    log_info "✓ Configuração válida!"
  else
    log_warn "Configuração gerada, mas falhou na validação do niri"
    log_warn "Verifique os módulos e execute novamente"
    exit 1
  fi
else
  log_warn "niri não encontrado - pulando validação"
fi

log_info "Concluído! Recarregue o niri com Mod+Shift+C ou 'niri msg reload-config'"
