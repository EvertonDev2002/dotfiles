#!/bin/bash
# scripts/setup/setup_repos.sh
# Configura repositórios Artix e Arch Linux

# shellcheck source=./lib/bootstrap.sh
PATH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/lib/bootstrap.sh" 2>/dev/null; then
    # shellcheck disable=SC1091
    source "$PATH_BOOTSTRAP"
fi

PACMAN_CONF="/etc/pacman.conf"
BACKUP_CONF="/etc/pacman.conf.backup-$(date +%Y%m%d-%H%M%S)"

log "Iniciando configuração de repositórios..."

# Backup do pacman.conf original (uma única vez)
if ! ls /etc/pacman.conf.backup-* &>/dev/null; then
    log "Criando backup de ${PACMAN_CONF}..."
    sudo cp "${PACMAN_CONF}" "${BACKUP_CONF}"
    success "Backup criado: ${BACKUP_CONF}"
else
    success "Backup anterior já existe"
fi

# Otimizações no pacman.conf
log "Aplicando otimizações no pacman.conf..."

# Habilitar ParallelDownloads se não existir
if ! grep -q "^ParallelDownloads" "${PACMAN_CONF}"; then
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 12/' "${PACMAN_CONF}"
    success "ParallelDownloads ativado"
else
    success "ParallelDownloads já está ativo"
fi

# Habilitar DownloadUser se não existir
if ! grep -q "^DownloadUser" "${PACMAN_CONF}"; then
    if grep -q "^#DownloadUser" "${PACMAN_CONF}"; then
        sudo sed -i 's/^#DownloadUser.*/DownloadUser = alpm/' "${PACMAN_CONF}"
    else
        sudo sed -i '/^ParallelDownloads/a DownloadUser = alpm' "${PACMAN_CONF}"
    fi
    success "DownloadUser configurado"
else
    success "DownloadUser já está ativo"
fi

# Habilitar Color se não existir
if ! grep -q "^Color" "${PACMAN_CONF}"; then
    sudo sed -i 's/^#Color/Color/' "${PACMAN_CONF}"
    success "Color ativado"
else
    success "Color já está ativo"
fi

# Descomentar HookDir se estiver comentado
if grep -q "^#HookDir" "${PACMAN_CONF}"; then
    sudo sed -i 's/^#HookDir/HookDir/' "${PACMAN_CONF}"
    success "HookDir descomentado"
elif grep -q "^HookDir" "${PACMAN_CONF}"; then
    success "HookDir já está ativo"
fi

# Adicionar IgnorePkg para systemd (evita conflitos no Artix)
if ! grep -q "^IgnorePkg.*systemd" "${PACMAN_CONF}"; then
    if grep -q "^#IgnorePkg" "${PACMAN_CONF}"; then
        sudo sed -i 's/^#IgnorePkg.*/IgnorePkg = systemd systemd-libs systemd-sysv libsystemd systemd-resolvconf systemd-sysvcompat systemd-tests systemd-ukify/' "${PACMAN_CONF}"
    else
        sudo sed -i '/^#IgnorePkg/a IgnorePkg = systemd systemd-libs systemd-sysv libsystemd systemd-resolvconf systemd-sysvcompat systemd-tests systemd-ukify' "${PACMAN_CONF}"
    fi
    success "IgnorePkg para systemd configurado"
else
    success "IgnorePkg já está configurado"
fi

# Instalar keyrings e suporte
log "Instalando keyrings necessários..."
sudo pacman -Sy --noconfirm artix-keyring
sudo pacman -S --needed --noconfirm artix-archlinux-support
success "Keyrings instalados"

#
# 1. Repositórios Artix (já configurados)
#
log "Verificando repositórios Artix..."
if grep -q "^\[system\]" "${PACMAN_CONF}" && grep -q "^\[world\]" "${PACMAN_CONF}" && grep -q "^\[galaxy\]" "${PACMAN_CONF}"; then
    success "Repositórios Artix (system, world, galaxy) detectados"
else
    warn "Repositórios Artix não encontrados ou incompletos"
fi

#
# 2. Repositório Arch [extra]
#
# Documentação Artix: https://wiki.artixlinux.org/Main/Repositories
if ! grep -q "\[extra\]" "${PACMAN_CONF}"; then
    log "Ativando repositório Arch [extra]..."

    # Adiciona [extra] no final do arquivo
    echo -e "\n# Arch\n[extra]\nInclude = /etc/pacman.d/mirrorlist-arch" | sudo tee -a "${PACMAN_CONF}" >/dev/null

    # Popular chaves do Arch
    sudo pacman-key --populate archlinux
    success "Repositório Arch [extra] ativado"
else
    warn "Repositório Arch [extra] já configurado"
fi

log "Atualizando bases de dados..."
sudo pacman -Sy

success "Configuração de repositórios concluída!"
echo "Backup original: ${BACKUP_CONF}"
