# --- Kitty

#alias icat="kitty +kitten icat"
#alias kdiff="kitty +kitten diff"
#alias khint="kitty +kitten hints"

# --- Gerenciamento de Serviços

#alias ls-service-running="systemctl list-units --type=service --state=running"
#alias ls-service-runit="sudo sv status /etc/runit/runsvdir/default/*"

# --- Gerenciamento de Pacotes

alias add-arch="paru -S --needed --noconfirm"
alias remove-arch="paru -Rns"
alias update-arch="flatpak update -y; and paru -Syu --noconfirm; and paru -c"
alias flatpak-search="flatpak search --columns=name,application"
#alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg; and sudo mkinitcpio -P"

# --- Antivirus

#alias update-av="sudo freshclam"
#alias scan-virus="sudo clamscan -r -i"

# --- Utilitários Modernos

alias cp="xcp --recursive --verbose"
alias mkdir="mkdir -pv"
alias ls="eza --icons --classify --group-directories-first"
alias ll="eza -l --icons --group-directories-first --time-style=relative --git"
alias cat="bat --style=auto --paging=auto"
alias lt="eza --tree --level=2 --icons"
alias find="fd --hidden --follow --exclude .git"
alias grep="rg --smart-case --hidden --follow --glob '!.git'"
