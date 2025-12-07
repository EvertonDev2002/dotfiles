#!/usr/bin/env bash

# ==============================================================================
# update-keys.sh
# Sincroniza atalhos do River WM (init) com um arquivo de descrições (.db)
# ==============================================================================

# --- BOAS PRÁTICAS: MODO ESTRITO ---
set -euo pipefail
IFS=$'\n\t'

# --- CONFIGURAÇÕES ---
INIT_FILE="$HOME/.config/river/init"
DB_FILE="$HOME/.local/share/river/shortcuts.db"
BACKUP_FILE="${DB_FILE}.bak"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- FUNÇÕES ---

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_err() { echo -e "${RED}[ERRO]${NC} $1"; }

# --- EXECUÇÃO ---

# 1. Verificações Iniciais
if [[ ! -f "$INIT_FILE" ]]; then
    log_err "Arquivo init não encontrado em: $INIT_FILE"
    exit 1
fi

# Garante que o diretório e arquivo DB existam
if [[ ! -f "$DB_FILE" ]]; then
    mkdir -p "$(dirname "$DB_FILE")"
    touch "$DB_FILE"
    log_info "Banco de dados criado em: $DB_FILE"
else
    # Cria backup por segurança
    cp "$DB_FILE" "$BACKUP_FILE"
fi

log_info "Lendo atalhos do River..."

# 2. Extração dos atalhos (Lógica de Parsing)
# Extrai: TECLAS|COMANDO
# Nota: Usamos mapfile para ler a saída do processo para um array de forma segura
mapfile -t NEW_MAPS < <(grep -E "^\s*map\s+" "$INIT_FILE" | \
    sed -E 's/^\s*map\s+//' | \
    sed 's/\$mod/Super/g' | \
    sed 's/spawn //g' | \
    sed 's/"//g' | \
    awk '{
        # $1 e $2 são as teclas (Ex: Super T)
        keys = $1 " " $2;
        $1=""; $2=""; 
        # O resto é o comando
        cmd=$0; 
        # Remove espaços em branco do início do comando
        sub(/^\s+/, "", cmd);
        print keys "|" cmd
    }')

COUNT_NEW=0
COUNT_CONFLICT=0

for line in "${NEW_MAPS[@]}"; do
    # Separa a linha em variáveis
    KEY="${line%%|*}" # Pega tudo antes do primeiro |
    CMD="${line#*|}"  # Pega tudo depois do primeiro |

    # Verifica se a chave já existe no arquivo DB (busca exata)
    if grep -F -q "$KEY|" "$DB_FILE"; then
        # Se existe, verificamos se o comando mudou (Conflito)
        EXISTING_CMD=$(grep -F "$KEY|" "$DB_FILE" | cut -d'|' -f2)
        
        # Trim (remove espaços nas pontas para comparação justa)
        CMD_TRIM=$(echo "$CMD" | xargs)
        EXISTING_TRIM=$(echo "$EXISTING_CMD" | xargs)

        if [[ "$CMD_TRIM" != "$EXISTING_TRIM" ]]; then
            log_warn "Conflito na tecla '$KEY':"
            echo "      Init diz: $CMD_TRIM"
            echo "      DB diz:   $EXISTING_TRIM"
            ((COUNT_CONFLICT++))
        fi
    else
        # Se não existe, adiciona no final
        echo "$KEY|$CMD|" >> "$DB_FILE"
        log_success "Novo atalho adicionado: $KEY"
        ((COUNT_NEW++))
    fi
done

echo "------------------------------------------------"
log_info "Sincronização concluída."
echo "Novos: $COUNT_NEW | Conflitos: $COUNT_CONFLICT"
echo "Edite as descrições em: $DB_FILE"