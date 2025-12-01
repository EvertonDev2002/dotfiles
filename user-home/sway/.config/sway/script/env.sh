#!/bin/bash

# Greetd
# Configure em: /etc/greetd/config.toml

# Ly
# configure em:  /usr/share/wayland-sessions/

. "$HOME/.config/wayland-common.sh" sway

exec dbus-run-session sway
