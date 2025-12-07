#!/usr/bin/env bash

# ==============================================================================
# show-keys.sh
# Lê o arquivo .db e exibe no Rofi formatado
# ==============================================================================

# --- CONFIGURAÇÃO ---
DB_FILE="$HOME/.local/share/river/shortcuts.db"

# --- VERIFICAÇÃO ---
if [[ ! -f "$DB_FILE" ]]; then
    # Se não existir, tenta notificar ou abre um terminal de aviso
    if command -v notify-send >/dev/null; then
        notify-send "Erro River" "Arquivo shortcuts.db não encontrado."
    else
        echo "Erro: $DB_FILE não encontrado."
    fi
    exit 1
fi

# --- PROCESSAMENTO E EXIBIÇÃO ---
# Awk é a melhor ferramenta aqui para performance de texto
awk -F '|' '{
    # Definição das colunas
    key = $1;
    cmd = $2;
    desc = $3;

    # Trim (limpeza de espaços brancos nas bordas)
    gsub(/^\s+|\s+$/, "", key);
    gsub(/^\s+|\s+$/, "", cmd);
    gsub(/^\s+|\s+$/, "", desc);

    # Lógica de Exibição:
    # Prioridade: Descrição > Comando
    if (desc != "") {
        display_text = desc
    } else {
        # Se não tiver descrição, mostra o comando entre parênteses para indicar que é técnico
        display_text = "⚙ " cmd
    }

    # Só imprime se tiver uma tecla válida
    if (key != "") {
        # Formatação:
        # %-22s : Coluna da tecla com largura fixa de 22 caracteres
        printf "%-22s  %s\n", key, display_text
    }
}' "$DB_FILE" | \
rofi -dmenu -i -p "Atalhos" -theme-str 'window {width: 900px;} listview {lines: 15;}'