# --- VARIÁVEIS GLOBAIS
set -gx EDITOR nano
set -gx VISUAL nano

# --- GERENCIAMENTO DE PATH
set -gx PNPM_HOME "$HOME/.local/share/pnpm"

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
    # Prompt
    starship init fish | source
    
    # Navigation
    zoxide init fish | source
    
    # Shell greeting
    set fish_greeting
    
    # Aliases
    if test -f ~/.config/fish/aliases.fish
        source ~/.config/fish/aliases.fish
    end
end
