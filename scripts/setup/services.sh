#!/bin/bash
# setup_services.sh - Habilitar Serviços Runit

# shellcheck source=./lib/bootstrap.sh
PATH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/lib/bootstrap.sh" 2>/dev/null; then
    # shellcheck disable=SC1091
    source "$PATH_BOOTSTRAP"
fi

# --- Habilitar Serviços Runit
log "Configurando serviços do Runit..."
echo ""

enabled=0
existing=0
not_found=0

enable_service() {
    local service="$1"
    if [ -d "/etc/runit/sv/$service" ]; then
        if [ ! -L "/etc/runit/runsvdir/default/$service" ]; then
            log "Habilitando serviço: $service"
            sudo ln -s "/etc/runit/sv/$service" "/etc/runit/runsvdir/default"
            success "$service habilitado"
            ((enabled++))
        else
            success "$service já está ativo"
            ((existing++))
        fi
    else
        warn "Serviço '$service' não encontrado. Pacote instalado?"
        ((not_found++))
    fi
}

# Lista de serviços
# Caso precise do preload, adicione na lista
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
    "seatd"
    "sshd"
    "udevd"
    "zramen"
)

for service in "${services[@]}"; do
    enable_service "$service"
done

echo ""
echo "────────────────────────────────────────────"
success "Configuração de serviços concluída!"
echo "  Habilitados: $enabled"
echo "  Já ativos: $existing"
echo "  Não encontrados: $not_found"
echo "────────────────────────────────────────────"
