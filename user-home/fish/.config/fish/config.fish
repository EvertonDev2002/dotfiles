if status is-interactive
    # Inicializa Starship
    starship init fish | source

    # Desabilita saudação do Fish
    set fish_greeting

    # Editor padrão
    set -gx EDITOR nano
    set -gx VISUAL nano

    # Ativa mise para shell interativo
    mise activate fish | source
else
    # Ativa mise para shell não-interativo
    mise activate fish --shims | source
end

# Carrega aliases
source ~/.config/fish/aliases.fish

# Configura pnpm
set -gx PNPM_HOME "/home/roneki/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
