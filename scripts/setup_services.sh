#!/bin/bash
# setup_services.sh - Habilitar Serviços Runit
# Autor: EvertonDev2002

# --- Cores e Formatação
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }

set -e

# --- Habilitar Serviços Runit
log "Configurando serviços do Runit..."

enable_service() {
    local service="$1"
    if [ -d "/etc/runit/sv/$service" ]; then
        if [ ! -L "/etc/runit/runsvdir/default/$service" ]; then
            log "Habilitando serviço: $service"
            sudo ln -s "/etc/runit/sv/$service" "/etc/runit/runsvdir/default"
        else
            echo " -> $service já está ativo."
        fi
    else
        warn "Serviço '$service' não encontrado em /etc/runit/sv. O pacote foi instalado?"
    fi
}

# Lista de serviços
services=(
    "NetworkManager"
    "bluetoothd"
    "docker"
    "tlp"
    "ufw"
    "acpid"
    "chrony"
    "dbus"
    "earlyoom"
    "greetd"
    "iwd"
    "lm_sensors"
    "preload"
    "seatd"
    "sshd"
    "udevd"
    "zramen"
)

for service in "${services[@]}"; do
    enable_service "$service"
done

success "Configuração de serviços concluída!"
