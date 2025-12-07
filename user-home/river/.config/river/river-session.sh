#!/bin/bash

# Greetd
# Configure em: /etc/greetd/config.toml

# Ly
# configure em:  /usr/share/wayland-sessions/

. "$HOME/.local/bin/wayland-common.sh" river

exec dbus-run-session river -no-xwayland
