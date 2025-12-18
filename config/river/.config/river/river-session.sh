#!/bin/bash

# Greetd
# Configure em: /etc/greetd/config.toml

# Ly
# configure em:  /usr/share/wayland-sessions/

. /etc/profile
if [ -f /etc/environment ]; then
    set -a
    . /etc/environment
    set +a
fi

if [ -f "$HOME/.local/bin/wayland-common.sh" ]; then
   . "$HOME/.local/bin/wayland-common.sh" river
fi

# --- Idioma (garantia)
export LANG=${LANG:-pt_BR.UTF-8} 
export LC_ALL=${LC_ALL:-pt_BR.UTF-8}

exec dbus-run-session river