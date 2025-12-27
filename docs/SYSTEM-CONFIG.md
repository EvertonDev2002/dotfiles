# Configurações do Sistema

Documentação das configurações de sistema aplicadas via `system/`.

## 󰋗 Índice

- [NumLock Automático](#numlock-automático)
- [Greetd](#greetd)
- [NetworkManager](#networkmanager)
- [TLP (Gerenciamento de Energia)](#tlp)
- [Limine (Bootloader)](#limine)

---

## NumLock Automático

### 󰋗 Configuração via udev

O NumLock é ativado automaticamente através de regra udev em `system/etc/udev/rules.d/90-numlock.rules`.

**Funcionamento:**

- Detecta qualquer teclado conectado (USB, Bluetooth, interno)
- Ativa NumLock automaticamente usando `setleds`
- Funciona em TTY e Wayland (River, Sway, Hyprland, etc.)
- Independente do compositor ou ambiente gráfico

**Instalação:**

```bash
# Copiar regra para o sistema
sudo cp system/etc/udev/rules.d/90-numlock.rules /etc/udev/rules.d/

# Recarregar regras udev
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=input --attr-match=name="*keyboard*"
```

**Verificação:**

```bash
# Testar ativação manual
setleds -D +num

# Verificar regras udev ativas
udevadm info -e | grep -A 5 "ID_INPUT_KEYBOARD=1"

# Listar dispositivos de entrada
lsinput
```

**Dependências:**

- `kbd` (fornece `setleds` - já presente no sistema base)

**Nota:** Esta configuração substitui `numlockx` e funciona em nível de sistema, sendo mais confiável que scripts de inicialização.

---

## Greetd

**Arquivo:** `system/etc/greetd/config.toml`

Login manager minimalista com interface TUI (tuigreet).

**Instalação:**

```bash
sudo cp system/etc/greetd/config.toml /etc/greetd/
sudo sv restart greetd
```

---

## NetworkManager

**Diretório:** `system/etc/NetworkManager/conf.d/`

Configurações do NetworkManager:

- **dns-servers.conf**: Servidores DNS (Cloudflare, Google)
- **iwd.conf**: Backend iwd para Wi-Fi
- **dhcp.conf**: Cliente DHCP (dhclient)
- **macrandomize.conf**: Randomização de MAC address

**Instalação:**

```bash
sudo cp system/etc/NetworkManager/conf.d/* /etc/NetworkManager/conf.d/
sudo sv restart NetworkManager
```

---

## TLP (Gerenciamento de Energia)

**Arquivo:** `system/etc/tlp.conf`

Otimizações de energia para laptops.

**Instalação:**

```bash
sudo cp system/etc/tlp.conf /etc/
sudo sv restart tlp
```

---

## Limine (Bootloader)

**Arquivo:** `system/example/limine.conf.example`

Configuração do bootloader Limine.

**Nota:** Este arquivo deve ser personalizado para cada instalação (UUIDs, kernel version, etc.).

**Instalação:**

```bash
# 1. Copiar e editar
cp system/example/limine.conf.example system/limine.conf
# Edite system/limine.conf com seus UUIDs e configurações

# 2. Copiar para ESP
sudo cp system/limine.conf /boot/limine/limine.conf
```

---

## 󰋗 Hooks do Pacman

**Diretório:** `system/etc/pacman.d/hooks/`

- **limine-update.hook**: Reinstala Limine após atualizações
- **cp-kernel-esp.hook**: Copia kernel para ESP após atualizações

**Instalação:**

```bash
sudo cp system/etc/pacman.d/hooks/* /etc/pacman.d/hooks/
```

---

## 󰋗 Runit Services

**Diretório:** `system/etc/runit/sv/`

Serviços customizados para runit:

- **preload**: Serviço de pré-carregamento de aplicações frequentes

**Instalação:**

```bash
# Copiar serviço
sudo cp -r system/etc/runit/sv/preload /etc/runit/sv/

# Habilitar
sudo ln -s /etc/runit/sv/preload /run/runit/service/
```

---

## 󰋗 Nano

**Arquivo:** `system/etc/nanorc`

Configuração global do nano com syntax highlighting.

**Instalação:**

```bash
sudo cp system/etc/nanorc /etc/
```

---

## 󰋗 Security Limits

**Arquivo:** `system/etc/security/limits.conf`

Limites de recursos do sistema.

**Instalação:**

```bash
sudo cp system/etc/security/limits.conf /etc/security/
```

---

## 󰋗 Sensors

**Diretório:** `system/etc/sensors.d/`

Configurações de sensores de hardware (lm_sensors).

**Instalação:**

```bash
sudo cp system/etc/sensors.d/* /etc/sensors.d/
```

---

## 󰀦 Arquivos de Exemplo

Os seguintes arquivos em `system/example/` devem ser personalizados para cada instalação:

- **fstab.example**: Tabela de sistemas de arquivos
- **limine.conf.example**: Configuração do bootloader

**Nunca copie arquivos `.example` diretamente para o sistema sem personalização!**
