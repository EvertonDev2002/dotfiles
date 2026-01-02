#!/bin/bash
# scripts/lib/bootstrap.sh
# Inicializa variáveis comuns para todos os scripts

# Encontra o diretório raiz dos scripts
find_scripts_root() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"

    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/lib/common.sh" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    echo "Erro: Não foi possível encontrar o diretório scripts/" >&2
    exit 1
}

SCRIPTS_ROOT="$(find_scripts_root)"
DOTFILES_DIR="$(dirname "$SCRIPTS_ROOT")"
SYSTEM_DIR="${DOTFILES_DIR}/system/etc"
export SCRIPTS_ROOT
export DOTFILES_DIR
export SYSTEM_DIR

# shellcheck disable=SC1091
source "${SCRIPTS_ROOT}/lib/common.sh"
