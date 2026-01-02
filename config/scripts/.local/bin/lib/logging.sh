#!/bin/bash
#
#  LOGGING LIBRARY - Funções padronizadas de log
#  Biblioteca comum para todos os scripts de inicialização
#

# Proteção contra múltiplos carregamentos
if [ -n "${LOGGING_LIB_LOADED:-}" ]; then
    return 0
fi
readonly LOGGING_LIB_LOADED=1

# Detectar se output é para terminal
if [ -t 1 ]; then
    # Terminal: usa cores
    readonly BLUE='\033[0;34m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly RED='\033[0;31m'
    readonly GRAY='\033[0;90m'
    readonly NC='\033[0m'
else
    # Arquivo: sem cores
    readonly BLUE=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly RED=''
    readonly GRAY=''
    readonly NC=''
fi

# Função para timestamp consistente
_log_timestamp() {
    date '+%H:%M:%S'
}

# Log INFO (azul)
log_info() {
    local msg="$1"
    echo -e "${BLUE}[INFO]${NC} [$(_log_timestamp)] ${msg}"
}

# Log SUCCESS (verde)
log_success() {
    local msg="$1"
    echo -e "${GREEN}[OK]${NC} [$(_log_timestamp)] ${msg}"
}

# Log WARN (amarelo)
log_warn() {
    local msg="$1"
    echo -e "${YELLOW}[WARN]${NC} [$(_log_timestamp)] ${msg}"
}

# Log ERROR (vermelho)
log_error() {
    local msg="$1"
    echo -e "${RED}[ERRO]${NC} [$(_log_timestamp)] ${msg}" >&2
}

# Log DEBUG (cinza) - apenas se DEBUG=1
log_debug() {
    local msg="$1"
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${GRAY}[DEBUG]${NC} [$(_log_timestamp)] ${msg}"
    fi
}

# Separador visual
log_separator() {
    echo "────────────────────────────────────────────────"
}

# Header de seção
log_header() {
    local title="$1"
    echo ""
    log_separator
    echo -e "${BLUE}${title}${NC}"
    log_separator
}

# Alias para compatibilidade com código existente
log() {
    log_info "$1"
}

# Função para setup inicial de logs
setup_logging() {
    local log_file="$1"
    local log_name="${2:-$(basename "$0" .sh)}"
    
    # Criar diretório de logs se não existir
    mkdir -p "$(dirname "$log_file")"
    rm -f "$log_file"
    
    # Redirecionar stdout e stderr para arquivo
    exec >> "$log_file" 2>&1
    
    # Header inicial
    log_header "Iniciando: $log_name"
    log_info "Data: $(date '+%d/%m/%Y %H:%M:%S')"
    log_info "Log: $log_file"
    log_separator
    echo ""
}

# Função para finalizar logs
finish_logging() {
    local status="${1:-0}"
    local script_name="${2:-Script}"
    
    echo ""
    log_separator
    if [ "$status" -eq 0 ]; then
        log_success "$script_name finalizado com sucesso"
    else
        log_error "$script_name finalizado com erros (código: $status)"
    fi
    log_separator
}
