# ============================================================================
# VARIÁVEIS GLOBAIS
# ============================================================================

set -gx EDITOR nano
set -gx VISUAL nano

set -gx PNPM_HOME "/home/roneki/.local/share/pnpm"

# ============================================================================
# GERENCIAMENTO DE PATH
# ============================================================================

fish_add_path "$HOME/.local/bin"
fish_add_path "$PNPM_HOME"

# ============================================================================
# FERRAMENTAS DE VERSÃO (MISE)
# ============================================================================

if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end

# ============================================================================
# SESSÃO INTERATIVA
# ============================================================================

if status is-interactive
    starship init fish | source
    zoxide init fish | source

    set fish_greeting
    
    abbr -a -- add-arch 'yay -S --needed --noconfirm'
    abbr -a -- remove-arch 'yay -Rns'
    abbr -a -- update-arch 'flatpak update -y; and yay -Syu --noconfirm; and yay -Yc'
    abbr -a -- flatpak-search 'flatpak search --columns=name,application'
    abbr -a -- grub-update 'sudo grub-mkconfig -o /boot/grub/grub.cfg; and sudo mkinitcpio -P'
    abbr -a -- cp 'xcp'
    abbr -a -- mkdir 'mkdir -pv'
    abbr -a -- ls 'eza --icons --classify --group-directories-first'
    abbr -a -- ll 'eza -l --icons --group-directories-first --time-style=relative --git'
    abbr -a -- cat 'bat'
    abbr -a -- lt 'eza --tree --level=2 --icons'    

    if test -f ~/.config/fish/aliases.fish
        source ~/.config/fish/aliases.fish
    end
end
