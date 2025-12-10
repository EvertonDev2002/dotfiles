#!/usr/bin/env bash

# ==============================================================================
# show-keys.sh - VERSÃO MELHORADA
# Lê o arquivo .db e exibe no Rofi formatado com cores e categorias
# ==============================================================================

# --- CONFIGURAÇÃO ---
DB_FILE="$HOME/.local/share/river/shortcuts.db"
#ROFI_THEME="$HOME/.config/rofi/keybindings.rasi"  # Tema opcional

# --- VERIFICAÇÃO ---
if [[ ! -f "$DB_FILE" ]]; then
    if command -v notify-send >/dev/null; then
        notify-send -u critical "Erro River" "Arquivo shortcuts.db não encontrado."
    fi
    echo "Erro: $DB_FILE não encontrado."
    echo "Execute: ~/.local/bin/update-keys.sh"
    exit 1
fi

# --- PROCESSAMENTO E EXIBIÇÃO ---
awk -F '|' '
BEGIN {
    # Cabeçalho
    header = sprintf("%-28s  %s\n", "TECLA", "AÇÃO");
    separator = "─────────────────────────────────────────────────────────────────────────";
    print header;
    print separator;
}
{
    # Definição das colunas
    key = $1;
    cmd = $2;
    desc = $3;

    # Trim (limpeza de espaços brancos)
    gsub(/^\s+|\s+$/, "", key);
    gsub(/^\s+|\s+$/, "", cmd);
    gsub(/^\s+|\s+$/, "", desc);

    # Lógica de Exibição
    if (desc != "") {
        display_text = desc;
    } else if (cmd != "") {
        # Se não tiver descrição, mostra comando com indicador
        display_text = "⚙️  " cmd;
    } else {
        # Pular linhas vazias
        next;
    }

    # Só imprime se tiver tecla válida
    if (key != "") {
        # Formatação com ícone
        printf "%-28s  %s%s\n", key, icon, display_text;
    }
}
' "$DB_FILE" | \
rofi -dmenu -i \
    -p "Atalhos do River" \
    -l 20 \
    -theme-str 'window {width: 900px hih;} listview {lines: 20;}' \
    -no-custom

# Alternativa: Se quiser usar um tema customizado
# rofi -dmenu -i -p "Atalhos do River" -theme "$ROFI_THEME"