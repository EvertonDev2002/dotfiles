#alias icat="kitty +kitten icat"
#alias kdiff="kitty +kitten diff"
#alias khint="kitty +kitten hints"

alias ls-service-running="systemctl list-units --type=service --state=running"
alias ls-service-runit="sudo sv status /etc/runit/runsvdir/default/*"

alias add-arch="yay -S --needed  --noconfirm"
alias update-arch="flatpak update -y; yay -Syu --noconfirm; yay -Qdtq | yay -Rns -a -; yay -Yc"
alias remove-arch="yay -Rns"

#alias update-av="sudo freshclam"
#alias scan-virus="sudo clamscan -r -i"

alias flatpak-search="flatpak search --columns=name,application"

alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg; sudo mkinitcpio -P"
