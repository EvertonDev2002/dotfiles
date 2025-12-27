# Instruções - SysAdmin & Linux Hardening

Este arquivo foi sucintamente reorganizado para LLMs.

- `linux-hardening.md` — SSH hardening, systemd sandboxing, firewall (nftables) e checklists de segurança.
- `ansible.md` — automação idempotente para configuração de servidores.

Gere com:

```bash
./scripts/tools/generate.sh linux-hardening ansible
```

Os arquivos são curtos, direcionados ao LLM (ações seguras, exemplos e rollback/backup quando pertinente).

### Validação de Sintaxe

**SEMPRE sugira comandos de validação antes de aplicar mudanças em produção:**

```bash
# 󰄬 Nginx - validar configuração
nginx -t
sudo nginx -t -c /etc/nginx/nginx.conf

# 󰄬 SSH - validar sshd_config
sshd -t
sudo sshd -t -f /etc/ssh/sshd_config

# 󰄬 Sudoers - validar com visudo
sudo visudo -c
sudo visudo -c -f /etc/sudoers.d/myfile

# 󰄬 Systemd - validar unit file
systemd-analyze verify myservice.service

# 󰄬 Apache - validar configuração
apachectl configtest
apache2ctl -t

# 󰄬 Postfix - validar configuração
postfix check

# 󰄬 DNS/BIND - validar zone files
named-checkconf
named-checkzone example.com /etc/bind/db.example.com

# 󰄬 Firewall/nftables - validar antes de carregar
nft -c -f /etc/nftables.conf
```

**Workflow seguro:**

```bash
# 󰋗 1. Editar arquivo de configuração
sudo nano /etc/nginx/nginx.conf

# 󰌢 2. SEMPRE validar sintaxe
sudo nginx -t

# 󰄬 3. Se válido, aplicar
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "󰄬 Configuração aplicada com sucesso"
else
    echo "󰅙 Erro na configuração! Não foi aplicada."
    exit 1
fi
```

### Systemd Best Practices

```ini
# /etc/systemd/system/myapp.service

[Unit]
Description=My Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=myapp
Group=myapp

# 󰌢 Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/myapp
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictNamespaces=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6

# 󰄬 Restart policy
Restart=on-failure
RestartSec=10
StartLimitInterval=200
StartLimitBurst=5

# 󰋗 Working directory
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/server

# 󰋗 Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

**Validação e gestão:**

```bash
# 󰌢 Verificar segurança do serviço
systemd-analyze security myapp.service

# 󰄬 Habilitar e iniciar
systemctl enable --now myapp.service

# 󰋗 Monitorar logs
journalctl -u myapp.service -f

# 󰋗 Verificar status
systemctl status myapp.service
```

### Runit (Artix Linux)

```bash
# 󰋗 Estrutura de serviço runit
# /etc/runit/sv/myapp/
# ├── run           # Script principal
# ├── finish        # Cleanup
# ├── conf          # Config
# └── log/
#     └── run       # Logging

# /etc/runit/sv/myapp/run
#!/bin/sh
exec 2>&1
exec chpst -u myapp:myapp /opt/myapp/bin/server

# /etc/runit/sv/myapp/log/run
#!/bin/sh
exec svlogd -tt /var/log/myapp

# 󰄬 Habilitar serviço
ln -s /etc/runit/sv/myapp /run/runit/service/

# 󰋗 Gerenciar
sv status myapp
sv start myapp
sv stop myapp
sv restart myapp
```

### Networking Moderno

```bash
# 󰅙 EVITE (net-tools deprecated)
ifconfig eth0 192.168.1.100 netmask 255.255.255.0
route add default gw 192.168.1.1

# 󰄬 USE (iproute2)
ip addr add 192.168.1.100/24 dev eth0
ip link set eth0 up
ip route add default via 192.168.1.1

# 󰋗 Verificar configuração
ip addr show
ip route show
ip link show

# 󰋗 NetworkManager CLI
nmcli device status
nmcli connection show
nmcli connection up myconnection
```

### Firewall (nftables)

```bash
# 󰅙 EVITE (iptables legacy)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 󰄬 USE (nftables)
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # 󰌢 Default policies
    chain input {
        type filter hook input priority 0; policy drop;

        # 󰄬 Allow established connections
        ct state established,related accept

        # 󰄬 Allow loopback
        iif lo accept

        # 󰋗 Allow SSH (rate limited)
        tcp dport 22 ct state new limit rate 3/minute accept

        # 󰋗 Allow HTTP/HTTPS
        tcp dport { 80, 443 } accept

        # 󰋗 Drop invalid packets
        ct state invalid drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# 󰄬 Carregar configuração
nft -f /etc/nftables.conf

# 󰋗 Verificar regras
nft list ruleset
```

### Backup Strategy

```bash
#!/usr/bin/env bash
set -e

readonly BACKUP_DIR="/backup"
readonly RETENTION_DAYS=7
readonly DATE=$(date +%Y%m%d_%H%M%S)

# 󰋗 Backup de sistema
backup_system() {
    echo "󰋗 Iniciando backup do sistema..."

    # 󰄬 Backup de /etc
    tar -czf "${BACKUP_DIR}/etc-${DATE}.tar.gz" \
        --exclude='/etc/ssl/private' \
        /etc

    # 󰄬 Backup de homes (excluindo caches)
    tar -czf "${BACKUP_DIR}/home-${DATE}.tar.gz" \
        --exclude='*/.cache' \
        --exclude='*/.local/share/Trash' \
        /home

    # 󰄬 Lista de pacotes instalados
    pacman -Qqe > "${BACKUP_DIR}/pkglist-${DATE}.txt"

    echo "󰄬 Backup concluído"
}

# 󰋗 Backup de database
backup_database() {
    local db_name="$1"

    echo "󰋗 Backup do banco $db_name..."

    pg_dump -U postgres "$db_name" | \
        gzip > "${BACKUP_DIR}/${db_name}-${DATE}.sql.gz"

    echo "󰄬 Backup de $db_name concluído"
}

# 󰋗 Upload para S3
upload_to_s3() {
    echo "󰋗 Upload para S3..."

    aws s3 sync "${BACKUP_DIR}" \
        "s3://backups/$(hostname)/" \
        --exclude "*" \
        --include "*-${DATE}.*"

    echo "󰄬 Upload concluído"
}

# 󰋗 Limpeza de backups antigos
cleanup_old_backups() {
    echo "󰋗 Removendo backups antigos..."

    find "${BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} -delete

    echo "󰄬 Limpeza concluída"
}

# 󰄬 Main
main() {
    backup_system
    backup_database "production"
    upload_to_s3
    cleanup_old_backups
}

main
```

### Security Hardening

**SSH Hardening:**

```bash
# /etc/ssh/sshd_config

# 󰌢 Basic security
Port 2222                          # 󰋗 Use non-standard port
PermitRootLogin no                 # 󰌢 Never allow root login
PasswordAuthentication no          # 󰌢 Keys only
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 30

# 󰌢 Restrict access
AllowUsers admin deploy
DenyUsers root

# 󰌢 Modern crypto
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
KexAlgorithms curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# 󰄬 Validar e reload
sshd -t
systemctl reload sshd
```

**Fail2Ban:**

```ini
# /etc/fail2ban/jail.local

[DEFAULT]
# 󰋗 Ban time: 1 hour
bantime = 3600
findtime = 600
maxretry = 3
# 󰋗 Notificações
destemail = admin@example.com
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400

# 󰄬 Iniciar
systemctl enable --now fail2ban

# 󰋗 Monitorar
fail2ban-client status sshd
```

### Monitoring & Logs

```bash
# 󰋗 Monitoramento de recursos
htop
btop
glances

# 󰋗 Logs do sistema (systemd)
journalctl -xe                    # 󰋗 Últimos erros
journalctl -u nginx.service       # 󰋗 Serviço específico
journalctl --since "1 hour ago"   # 󰋗 Última hora
journalctl -f                     # 󰋗 Follow mode

# 󰋗 Disk usage
df -h
du -sh /var/*
ncdu /var

# 󰋗 Network monitoring
ss -tulpn                         # 󰋗 Portas abertas
nethogs                           # 󰋗 Uso de banda por processo
iftop                             # 󰋗 Tráfego de rede
```

### Automated Maintenance

```bash
# 󰋗 Systemd timer para limpeza
# /etc/systemd/system/cleanup.timer

[Unit]
Description=Daily system cleanup

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target

# /etc/systemd/system/cleanup.service

[Unit]
Description=System cleanup tasks

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cleanup.sh

# /usr/local/bin/cleanup.sh
#!/usr/bin/env bash
set -e

echo "󰋗 Limpando cache do pacman..."
paccache -rk2

echo "󰋗 Limpando journalctl..."
journalctl --vacuum-time=7d

echo "󰋗 Limpando /tmp..."
find /tmp -type f -atime +7 -delete

echo "󰄬 Limpeza concluída"

# 󰄬 Habilitar
systemctl enable --now cleanup.timer
```

## 󰋗 Checklist Sysadmin

Antes de deploy em produção:

- [ ] 󰌢 SSH hardening aplicado
- [ ] 󰌢 Firewall configurado (nftables)
- [ ] 󰌢 Fail2Ban ativo
- [ ] 󰄬 Backups automáticos configurados
- [ ] 󰄬 Monitoring/alerting configurado
- [ ] 󰌢 SELinux/AppArmor ativo
- [ ] 󰄬 Log rotation configurado
- [ ] 󰄬 Updates automáticos ou agendados
- [ ] 󰌢 Princípio do menor privilégio aplicado
- [ ] 󰄬 Documentação de runbooks atualizada

## 󰋗 Referências

- [Arch Wiki](https://wiki.archlinux.org/)
- [systemd Documentation](https://systemd.io/)
- [nftables Wiki](https://wiki.nftables.org/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Linux Hardening Guide](https://github.com/imthenachoman/How-To-Secure-A-Linux-Server)
