#!/bin/sh

pkill -u "$USER" -x pipewire || true
pkill -u "$USER" -x wireplumber || true
pkill -u "$USER" -x pipewire-pulse || true


sleep 0.5

/usr/bin/pipewire &
/usr/bin/wireplumber &
/usr/bin/pipewire-pulse &
