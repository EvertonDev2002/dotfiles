# Linux Hardening — Instruções para o LLM

Contexto: Segurança de servidores Linux (SSH, systemd, firewall).

## Objetivo do assistant

- Gerar configurações seguras para SSH, systemd units, firewall.
- Seguir princípio do menor privilégio (POLP).

## Estrutura esperada

### SSH Hardening (/etc/ssh/sshd_config)

```bash
# /etc/ssh/sshd_config

# Protocol and encryption
Protocol 2
Port 22
AddressFamily inet

# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Disable insecure options
X11Forwarding no
PermitUserEnvironment no
AllowAgentForwarding no
AllowTcpForwarding no
GatewayPorts no

# Security limits
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Crypto settings
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Allow specific users/groups only
AllowUsers deploy admin
# AllowGroups ssh-users

# Subsystems
Subsystem sftp /usr/lib/openssh/sftp-server
```

**Apply and verify:**

```bash
# Backup original
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Test configuration
sudo sshd -t

# Restart SSH (keep current session open!)
sudo systemctl restart sshd

# Verify from another terminal before closing
ssh -v user@server
```

### Systemd Service Sandboxing

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
WorkingDirectory=/opt/myapp

# Start command
ExecStart=/opt/myapp/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID

# Restart policy
Restart=on-failure
RestartSec=5s
TimeoutStopSec=30

# Security hardening
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/myapp /var/log/myapp
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
RestrictNamespaces=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
LockPersonality=yes
MemoryDenyWriteExecute=yes
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM

# Resource limits
LimitNOFILE=65536
LimitNPROC=512
MemoryMax=1G
CPUQuota=50%

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

**Validate security:**

```bash
# Analyze security score
sudo systemd-analyze security myapp.service

# Check for warnings
sudo systemd-analyze verify myapp.service

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now myapp.service

# Check status
sudo systemctl status myapp.service
journalctl -u myapp.service -f
```

### Firewall (nftables)

```bash
# /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority filter; policy drop;

    # Allow loopback
    iif lo accept

    # Allow established/related connections
    ct state established,related accept

    # Drop invalid packets
    ct state invalid drop

    # Allow ICMP (ping)
    icmp type echo-request limit rate 5/second accept
    icmpv6 type { echo-request, nd-neighbor-solicit, nd-neighbor-advert } accept

    # Allow SSH (rate limited)
    tcp dport 22 ct state new limit rate 3/minute accept

    # Allow HTTP/HTTPS
    tcp dport { 80, 443 } ct state new accept

    # Log dropped packets (optional)
    limit rate 5/minute log prefix "nftables-drop: " level info

    # Default drop
    counter drop
  }

  chain forward {
    type filter hook forward priority filter; policy drop;
  }

  chain output {
    type filter hook output priority filter; policy accept;
  }
}
```

**Apply and verify:**

```bash
# Backup current rules
sudo nft list ruleset > /etc/nftables.backup

# Test new rules
sudo nft -f /etc/nftables.conf

# Make persistent
sudo systemctl enable nftables
sudo systemctl restart nftables

# Verify rules
sudo nft list ruleset
```

### fail2ban Configuration

```ini
# /etc/fail2ban/jail.local
[DEFAULT]
bantime  = 1h
findtime  = 10m
maxretry = 3
backend = systemd
destemail = admin@example.com
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 6
```

```bash
# Test configuration
sudo fail2ban-client -t

# Restart service
sudo systemctl restart fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Unban IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

### AppArmor Profile

```
# /etc/apparmor.d/usr.bin.myapp
#include <tunables/global>

/usr/bin/myapp {
  #include <abstractions/base>

  # Program execution
  /usr/bin/myapp mr,

  # Config files
  /etc/myapp/** r,
  owner /etc/myapp/config.yml r,

  # Data directories
  owner /var/lib/myapp/** rw,
  owner /var/log/myapp/** w,

  # Temp files
  owner /tmp/** rw,

  # Network (if needed)
  network inet stream,
  network inet6 stream,

  # Deny everything else
  deny /proc/** w,
  deny /sys/** w,
}
```

```bash
# Load profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.myapp

# Check status
sudo aa-status

# Set to enforce mode
sudo aa-enforce /usr/bin/myapp

# Set to complain mode (for debugging)
sudo aa-complain /usr/bin/myapp

# View logs
sudo journalctl -xe | grep apparmor
```

### Kernel Hardening (sysctl)

```ini
# /etc/sysctl.d/99-hardening.conf

# IP forwarding (disable if not router)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Syn flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0

# Ignore source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Ignore broadcast pings
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1

# Protect against TCP time-wait assassination
net.ipv4.tcp_rfc1337 = 1

# Kernel pointer exposure
kernel.kptr_restrict = 2

# Restrict dmesg access
kernel.dmesg_restrict = 1

# Disable core dumps
kernel.core_uses_pid = 1
fs.suid_dumpable = 0
```

```bash
# Apply settings
sudo sysctl -p /etc/sysctl.d/99-hardening.conf

# Verify
sudo sysctl net.ipv4.tcp_syncookies
```

### Automatic Updates (Debian/Ubuntu)

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades apt-listchanges

# Configure
sudo dpkg-reconfigure -plow unattended-upgrades
```

```
# /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change";
```

## Restrições

- **Backups**: SEMPRE crie backup antes de modificar configs críticas
- **Testing**: teste SSH config antes de aplicar (`sshd -t`)
- **Sessions**: mantenha sessão SSH aberta ao modificar sshd_config
- **Principle of Least Privilege**: mínimas permissões necessárias
- **Logging**: habilite verbose logging para auditoria
- **Updates**: automatize security updates
- **Firewall**: default deny, explicit allow
- **Services**: disable desnecessários (`systemctl disable`)

## Comandos de auditoria

```bash
# Check listening ports
sudo ss -tulpn

# Check running services
sudo systemctl list-units --type=service --state=running

# Check users with shell access
grep -vE '(nologin|false)' /etc/passwd

# Check failed login attempts
sudo lastb

# Check sudo usage
sudo journalctl _COMM=sudo

# Scan for rootkits
sudo rkhunter --check
sudo lynis audit system

# Check file permissions
sudo find / -perm -4000 -ls  # SUID files
sudo find / -perm -2000 -ls  # SGID files

# SELinux/AppArmor status
sudo aa-status  # AppArmor
sestatus        # SELinux
```

## Checklist de hardening

- [ ] SSH: PasswordAuthentication no, PermitRootLogin no
- [ ] SSH: AllowUsers configurado, chavesEd25519
- [ ] fail2ban instalado e ativo
- [ ] Firewall configurado (nftables/ufw)
- [ ] systemd units com sandboxing
- [ ] AppArmor/SELinux habilitado
- [ ] Kernel hardening (sysctl)
- [ ] Updates automáticos configurados
- [ ] Logs centralizados e monitorados
- [ ] Backups regulares configurados
- [ ] Portas desnecessárias fechadas
- [ ] Serviços desnecessários desabilitados
- [ ] File permissions verificados (no SUID desnecessários)

## Saída esperada

1. sshd_config hardened
2. systemd unit com sandboxing completo
3. nftables rules com default deny
4. fail2ban configuration
5. sysctl kernel hardening
6. Comandos de validação e auditoria
