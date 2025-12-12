#!/usr/bin/env bash

# ==============================================================================
# update-keys.sh
# Sincroniza atalhos do River WM (init) com um arquivo de descrições (.db)
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# --- CONFIGURAÇÕES ---
INIT_FILE="$HOME/.config/river/init"
DB_FILE="$HOME/.local/share/river/shortcuts.db"
BACKUP_FILE="${DB_FILE}.bak"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- FUNÇÕES ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_err() { echo -e "${RED}[ERRO]${NC} $1"; }

# --- VERIFICAÇÕES INICIAIS ---
if [[ ! -f "$INIT_FILE" ]]; then
    log_err "Arquivo init não encontrado em: $INIT_FILE"
    exit 1
fi

if [[ ! -f "$DB_FILE" ]]; then
    mkdir -p "$(dirname "$DB_FILE")"
    touch "$DB_FILE"
    log_info "Banco de dados criado em: $DB_FILE"
else
    cp "$DB_FILE" "$BACKUP_FILE"
fi

log_info "Lendo atalhos do River..."

# --- EXTRAÇÃO DOS ATALHOS ---
# Passo 1: Expandir variáveis do shell primeiro
TEMP_INIT=$(mktemp)
trap "rm -f $TEMP_INIT" EXIT

# Copiar o init e expandir variáveis básicas
sed 's/\$mod/Super/g' "$INIT_FILE" > "$TEMP_INIT"

# Passo 2: Extrair mapeamentos
declare -a NEW_MAPS=()

# 2.1 - Capturar map normal (teclado)
while IFS= read -r line; do
    NEW_MAPS+=("$line")
done < <(grep -E '^\s*map\s+' "$TEMP_INIT" | \
    sed -E 's/^\s*map\s+//' | \
    sed 's/spawn //g' | \
    sed 's/"//g' | \
    awk '{
        # Modificadores podem ter + (Ex: Super+Shift)
        mods = $1;
        key = $2;
        
        # Juntar modificadores compostos
        if (mods ~ /\+/) {
            keys = mods " " key;
        } else {
            keys = mods " " key;
        }
        
        # O resto é o comando
        $1=""; $2="";
        cmd=$0;
        sub(/^\s+/, "", cmd);
        
        print keys "|" cmd
    }')

# 2.2 - Capturar map-pointer (mouse)
while IFS= read -r line; do
    NEW_MAPS+=("$line")
done < <(grep -E '^\s*map_pointer\s+' "$TEMP_INIT" | \
    sed -E 's/^\s*map_pointer\s+//' | \
    awk '{
        mods = $1;
        button = $2;
        keys = mods " " button;
        
        $1=""; $2="";
        cmd=$0;
        sub(/^\s+/, "", cmd);
        
        print keys "|" cmd " [MOUSE]"
    }')

# 2.3 - Capturar mapeamentos gerados em loops (tags 1-9)
# Adiciona manualmente os mapeamentos conhecidos do loop
for i in {1..9}; do
    NEW_MAPS+=("Super $i|set-focused-tags [Tag $i]")
    NEW_MAPS+=("Super+Shift $i|set-view-tags [Tag $i]")
    NEW_MAPS+=("Super+Control $i|toggle-focused-tags [Tag $i]")
    NEW_MAPS+=("Super+Shift+Control $i|toggle-view-tags [Tag $i]")
done

# 2.4 - Mapeamentos especiais do modo locked
while IFS= read -r line; do
    if [[ $line =~ XF86 ]]; then
        NEW_MAPS+=("$line [LOCKED]")
    fi
done < <(grep -E 'riverctl map \$mode None XF86' "$TEMP_INIT" | \
    sed 's/riverctl map \$mode None //' | \
    sed 's/spawn //g' | \
    sed "s/'//g" | \
    awk '{
        key = $1;
        $1="";
        cmd=$0;
        sub(/^\s+/, "", cmd);
        print key "|" cmd
    }')

# --- SINCRONIZAÇÃO ---
COUNT_NEW=0
COUNT_CONFLICT=0
COUNT_SKIP=0

for line in "${NEW_MAPS[@]}"; do
    # Pular linhas vazias
    [[ -z "$line" ]] && continue
    
    KEY="${line%%|*}"
    CMD="${line#*|}"
    
    # Trim
    KEY=$(echo "$KEY" | xargs)
    CMD=$(echo "$CMD" | xargs)
    
    # Pular se não tiver key válida
    [[ -z "$KEY" ]] && { ((COUNT_SKIP++)); continue; }
    
    # Verificar se já existe
    if grep -F "$KEY|" "$DB_FILE" >/dev/null 2>&1; then
        EXISTING_CMD=$(grep -F "$KEY|" "$DB_FILE" | cut -d'|' -f2 | xargs)
        CMD_TRIM=$(echo "$CMD" | xargs)
        
        if [[ "$CMD_TRIM" != "$EXISTING_CMD" ]]; then
            log_warn "Conflito: '$KEY'"
            echo "      Init: $CMD_TRIM"
            echo "      DB:   $EXISTING_CMD"
            ((COUNT_CONFLICT++))
        fi
    else
        # Adicionar novo atalho
        echo "$KEY|$CMD|" >> "$DB_FILE"
        log_success "Novo: $KEY"
        ((COUNT_NEW++))
    fi
done

# --- RESUMO ---
echo "================================================"
log_info "Sincronização concluída"
echo "Novos: $COUNT_NEW | Conflitos: $COUNT_CONFLICT | Ignorados: $COUNT_SKIP"
echo "Arquivo: $DB_FILE"
echo "Backup: $BACKUP_FILE"
echo ""
echo "📝 Edite as descrições manualmente:"
echo "   nano $DB_FILE"