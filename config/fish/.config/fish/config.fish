# --- VARIÁVEIS GLOBAIS

set -gx EDITOR nano
set -gx VISUAL nano 

set -gx PNPM_HOME "/home/roneki/.local/share/pnpm"

# --- GERENCIAMENTO DE PATH

fish_add_path "$HOME/.local/bin"
fish_add_path "$PNPM_HOME"

# --- FERRAMENTAS DE VERSÃO (MISE)

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

# --- SESSÃO INTERATIVA

if status is-interactive
    starship init fish | source
    zoxide init fish | source

    set fish_greeting

    if test -f ~/.config/fish/aliases.fish
        source ~/.config/fish/aliases.fish
    end
end
