# 🏠 Dotfiles - Artix Linux + River WM

Configurações pessoais para Artix Linux (Runit) com River (Wayland compositor), otimizadas para performance, privacidade e produtividade.

![Artix Linux](https://img.shields.io/badge/Artix_Linux-Runit-10b981?style=for-the-badge&logo=artixlinux)
![River WM](https://img.shields.io/badge/River-Wayland-0ea5e9?style=for-the-badge)
![Fish Shell](https://img.shields.io/badge/Fish-Shell-f59e0b?style=for-the-badge&logo=fishshell)

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Screenshots](#-screenshots)
- [Características](#-características)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Instalação](#-instalação)
- [Componentes](#-componentes)
- [Scripts de Configuração](#-scripts-de-configuração)
- [Customização](#-customização)
- [Créditos](#-créditos)
- [Licença](#-licença)

---

## 🎯 Visão Geral

Este repositório contém todas as configurações necessárias para replicar meu ambiente de desenvolvimento e uso diário:

- **Sistema**: Artix Linux (Runit init system - sem systemd)
- **Window Manager**: River (compositor Wayland minimalista)
- **Shell**: Fish com Oh My Fish, Starship prompt
- **Terminal**: Foot
- **Browser**: Firefox com configurações (Betterfox + Personal use)
- **Gerenciamento**: GNU Stow para symlinks automáticos
- **Pacotes**: Paru (AUR helper) + Flatpak

---

## 🖼️ Screenshots

---

## ✨ Características

### 🚀 Performance

- **Preload service** para cache inteligente de aplicações
- **Zramen** swap comprimido em memória
- **Pacman otimizado** (ParallelDownloads=12, DownloadUser=alpm)
- **PipeWire** com baixa latência
- **Aliases modernos** (fd, ripgrep, eza, bat, xcp)

### 🔒 Privacidade & Segurança

- **Firefox hardened** com 170+ preferências comentadas
- **DNS-over-HTTPS** (Cloudflare + Google fallback)
- **NetworkManager** com MAC randomization e DHCP privacy
- **TLP** para gerenciamento de energia
- **Limite de coredump** configurado

### 🎨 Interface

- **Tema GTK**: Colloid Grey
- **Ícones**: Tela Circle Blue
- **Curso**: Bibata Modern Ice
- **Waybar** com módulos customizados
- **Mako** para notificações
- **Fuzzel** para launchers
- **Swww** para wallpapers animados

### 🛠️ Ferramentas de Desenvolvimento

- **VSCode** com perfis e configurações
- **Git** com aliases e configurações
- **Fish shell** com autosuggestions e syntax highlighting
- **Mise** para gerenciamento de versões (Python, Node, etc.)

---

## 📁 Estrutura do Repositório

```
dotfiles/
├── browser
│   ├── extension
│   │   └── ublock
│   │       └── my-ublock-backup.txt
│   └── firefox
├── config
│   ├── alacritty
│   ├── code
│   ├── fastfetch
│   ├── fish
│   ├── foot
│   ├── fuzzel
│   ├── git
│   ├── gtk
│   ├── hyprland
│   ├── init-log
│   ├── kanshi
│   ├── kitty
│   ├── mako
│   ├── nautilus
│   ├── nwg
│   ├── omf
│   ├── river
│   ├── rofi
│   ├── scripts
│   ├── shikane
│   ├── shortcuts
│   ├── starship
│   ├── sway
│   ├── waybar
│   ├── way-displays
│   └── xdg-desktop-portal
├── pkgs
│   ├── flatpak
│   │   └── flatpaklist.txt
│   └── paru
│       └── pkglist.txt
├── scripts
│   ├── setup_firefox.sh
│   ├── setup_flatpaks.sh
│   ├── setup_repos.sh
│   ├── setup_system.sh
│   └── setup_themes.sh
├── system
│   ├── etc
│   │   ├── iwd
│   │   │   └── main.conf
│   │   ├── nanorc
│   │   ├── NetworkManager
│   │   │   └── conf.d
│   │   │       ├── dhcp.conf
│   │   │       ├── dns-servers.conf
│   │   │       ├── iwd.conf
│   │   │       └── macrandomize.conf
│   │   ├── pacman.d
│   │   │   └── hooks
│   │   │       └── 99-cp-kernel-esp.hook
│   │   ├── runit
│   │   │   └── sv
│   │   │       └── preload
│   │   │           ├── conf
│   │   │           ├── finish
│   │   │           ├── log
│   │   │           │   └── run
│   │   │           └── run
│   │   ├── security
│   │   │   └── limits.conf
│   │   ├── sensors.d
│   │   └── tlp.conf
│   └── example
│       └── fstab
├── uv.lock
├── pyproject.toml
├── README.md
└── install.sh
```

---

## 🚀 Instalação

### Pré-requisitos

- Artix Linux instalado (Runit)
- Acesso root (sudo)
- Conexão com internet

### Instalação Completa

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Execute o script de instalação principal
chmod +x install.sh
./install.sh
```

O script `install.sh` irá:

1. ✅ Instalar Paru (AUR helper)
2. ✅ Configurar repositórios (Arch extra)
3. ✅ Instalar pacotes do sistema (pkglist.txt)
4. ✅ Instalar Flatpaks (flatpaklist.txt)
5. ✅ Criar symlinks com GNU Stow
6. ✅ Configurar Firefox (detecção automática de perfil)
7. ✅ Copiar arquivos de sistema (/etc)
8. ✅ Habilitar serviços Runit

### Instalação Modular

Você pode executar scripts individuais:

```bash
# Apenas repositórios
./scripts/setup_repos.sh

# Apenas Flatpaks
./scripts/setup_flatpaks.sh

# Apenas Firefox
./scripts/setup_firefox.sh

# Apenas arquivos de sistema
./scripts/setup_system.sh

# Apenas temas e ícones
./scripts/setup_themes.sh
```

### Instalação Manual (Stow)

```bash
# Instalar configurações específicas
cd ~/dotfiles

# Fish shell
stow -d config -t ~ fish

# River WM
stow -d config -t ~ river

# Waybar
stow -d config -t ~ waybar

# Scripts utilitários
stow -d config -t ~ scripts

```

---

## 🧩 Componentes

### Window Manager - River

- **Compositor**: Wayland baseado em wlroots
- **Configuração**: `config/river/.config/river/init`
  <!-- - **Atalhos**: Documentados em `shortcuts.db` -->
  <!-- - **Scripts**: `show-keys.sh` para visualizar atalhos -->

**Recursos configurados:**

- Layouts dinâmicos com rivertile
- Touchpad com gestures
- Tiling automático
- Workspaces (tags) 1-9
- Scratchpad

### Shell - Fish

- **Framework**: Oh My Fish (OMF)
- **Prompt**: Starship
- **Plugins**:
  - `autopair` - Fecha parênteses automaticamente
  - `sponge` - Remove comandos falhados do histórico
  - `fzf` - Fuzzy finder integrado
  - `sudope` - Adiciona sudo ao apertar ESC

**Aliases úteis:**

```bash
# Paru (pacman wrapper)
alias add-arch="paru -S --needed --noconfirm"
alias remove-arch="paru -Rns"
alias update-arch="flatpak update -y; and paru -Syu --noconfirm; and paru -c"
alias flatpak-search="flatpak search --columns=name,application"

# Modern CLI tools
alias cp="xcp --recursive --verbose"
alias mkdir="mkdir -pv"
alias ls="eza --icons --classify --group-directories-first"
alias ll="eza -l --icons --group-directories-first --time-style=relative --git"
alias cat="bat --style=auto --paging=auto"
alias lt="eza --tree --level=2 --icons"
alias find="fd --hidden --follow --exclude .git"
alias grep="rg --smart-case --hidden --follow --glob '!.git'"
```

### Firefox - Hardened

Baseado em [Betterfox](https://github.com/yokoffing/Betterfox) com 170+ preferências organizadas:

**Seções:**

- ⚡ **Fastfox**: Performance e cache
- 🔒 **Securefox**: Segurança e tracking protection
- 🎨 **Customização UI**: Compact mode, smooth scroll
- 📡 **DNS-over-HTTPS**: Cloudflare + Google
- 🚫 **Telemetria**: Desabilitada completamente
- 🍪 **Cookies**: Configurações de privacidade

### Display Management

- **way-displays**: Auto-configuração de displays
- **wl-mirror**: Espelhamento de tela
- **wlr-randr**: Controle de outputs
<!-- - **kanshi**: Perfis de display por contexto -->

### Audio - PipeWire

```bash
# Stack completo
pipewire
pipewire-pulse
pipewire-alsa
wireplumber
```

Inicializado via `init-pipewire.sh` com logging em `~/.local/state/init-log/audio.log`

---

## 🔧 Scripts de Configuração

### Scripts de Inicialização (`config/scripts/.local/bin/`)

Todos os scripts possuem:

- ✅ Logging em `~/.local/state/init-log/`
- ✅ Error handling (`set -euo pipefail`)
- ✅ Paths dinâmicos com `$SCRIPT_DIR`

| Script              | Função                                      | Log                |
| ------------------- | ------------------------------------------- | ------------------ |
| `init-services.sh`  | Orquestra todos os serviços de usuário      | `services.log`     |
| `init-pipewire.sh`  | Inicia stack de áudio PipeWire              | `audio.log`        |
| `init-portals.sh`   | XDG Desktop Portals (wlr + generic)         | `portals.log`      |
| `init-clipboard.sh` | Clipboard manager (wl-clipboard + cliphist) | `clipboard.log`    |
| `init-autostart.sh` | UI components (waybar, mako, wallpaper)     | `autostart.log`    |
| `screenshot.sh`     | Captura de tela (grim + slurp)              | `screenshot.log`   |
| `powermenu.sh`      | Menu de energia (fuzzel)                    | -                  |
| `mirror_toggle.sh`  | Toggle espelhamento de display              | `mirror.log`       |
| `set-wallpaper.sh`  | Gerencia wallpapers com swww                | `wallpaper.log`    |

### Scripts de Setup (`scripts/`)

| Script              | Função                                           |
| ------------------- | ------------------------------------------------ |
| `setup_repos.sh`    | Configura Artix/CachyOS/Arch repos + pacman.conf |
| `setup_flatpaks.sh` | Instala Flatpak + Flathub + apps                 |
| `setup_firefox.sh`  | Detecta perfil e cria symlinks                   |
| `setup_system.sh`   | Copia /etc configs com backup                    |
| `setup_themes.sh`   | Copia temas/ícones de /usr/share                 |

---

## 🎨 Customização

### Temas e Cores

**GTK:**

```bash
# Alterar tema
gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Grey-Dark-Compact'

# Alterar ícones
gsettings set org.gnome.desktop.interface icon-theme 'Bibata-Modern-Ice'
```

**Waybar:**

- Editar cores: `config/waybar/.config/waybar/colors.css`
- Módulos: `config/waybar/.config/waybar/modules.jsonc`
- Layout: `config/waybar/.config/waybar/config.jsonc`

### Atalhos do River

Editar: `config/river/.config/river/init`

Após modificar:

```bash
# Atualizar database de atalhos
~/.local/bin/update-keys.sh

# Visualizar atalhos
~/.local/bin/show-keys.sh
```

### Aliases do Fish

Editar: `config/fish/.config/fish/aliases.fish`

Recarregar:

```bash
source ~/.config/fish/aliases.fish
```

---

## 🙏 Créditos

Este repositório foi construído com inspiração e código de várias fontes incríveis da comunidade:

### Firefox

- **[Betterfox](https://github.com/yokoffing/Betterfox)** - Base para user.js hardened e timizações de performance

### Temas & Estética

- **[Colloid](https://github.com/vinceliuice/Colloid-gtk-theme)** - Tema GTK
- **[Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor)** - Tema de cursor

<!-- ### Scripts & Tools -->

<!-- - **[Nome]** - [Link] - Descrição -->

---

## 📝 Notas

### Logs

Todos os logs ficam em `~/.local/state/init-log/`:

```bash
# Ver logs em tempo real
tail -f ~/.local/state/init-log/services.log

# Verificar erros
grep -i error ~/.local/state/init-log/*.log
```

### Backup

Antes de modificar configs de sistema:

```bash
# Scripts fazem backup automático em:
/etc/dotfiles-backup-YYYY-MM-DD_HH-MM-SS/
/etc/pacman.conf.backup-YYYY-MM-DD_HH-MM-SS
```

### Troubleshooting

**River não inicia:**

```bash
# Verificar log
cat ~/.local/state/init-log/river.log

# Verificar permissões
chmod +x ~/.config/river/init
```

**Waybar não aparece:**

```bash
# Verificar log
cat ~/.local/state/init-log/autostart.log

# Reiniciar waybar
killall waybar && waybar &
```

**Som não funciona:**

```bash
# Verificar PipeWire
cat ~/.local/state/init-log/audio.log

# Reiniciar serviço
~/.local/bin/init-pipewire.sh
```

---

## 📜 Licença

Este repositório é disponibilizado sob a licença MIT. Sinta-se livre para usar, modificar e compartilhar.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Se você encontrou um bug ou tem uma sugestão:

1. Abra uma Issue
2. Faça um Fork
3. Crie uma Branch (`git checkout -b feature/MinhaFeature`)
4. Commit suas mudanças (`git commit -m 'Add: Minha feature'`)
5. Push para a Branch (`git push origin feature/MinhaFeature`)
6. Abra um Pull Request
