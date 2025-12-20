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
- [Componentes](#-componentes)
- [Instalação](#-instalação)
- [Scripts de Configuração](#-scripts-de-configuração)
- [Customização](#-customização)
- [Notas](#-notas)
- [Licença](#-licença)
- [Contribuindo](#-contribuindo)

---

## 🎯 Visão Geral

Este repositório contém todas as configurações necessárias para replicar meu ambiente de desenvolvimento e uso diário:

- **Sistema**: Artix Linux (Runit init system - sem systemd)
- **Window Manager**: River (compositor Wayland minimalista)
- **Shell**: Fish com Fisher, Starship prompt
- **Terminal**: Kitty
- **Browser**: Firefox com configurações (Betterfox + Personal use)
- **Gerenciamento**: GNU Stow para symlinks automáticos
- **Pacotes**: Yay (AUR helper) + Flatpak

---

## 🖼️ Screenshots

---

## ✨ Características

### 🚀 Performance

- **Zramen** swap comprimido em memória
- **PipeWire** com baixa latência
- **Aliases modernos** (fd, ripgrep, eza, bat, xcp)
- **Pacman otimizado**

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
- **Fish shell** com autosuggestions, syntax highlighting e plugins
- **Mise** para gerenciamento de versões (Python, Node, etc.)

---

## 🧩 Componentes

### Window Manager - River

- **Compositor**: Wayland baseado em wlroots
- **Configuração**: `config/river/.config/river/init`

**Recursos configurados:**

- Layouts dinâmicos com rivertile
- Touchpad com gestures
- Tiling automático
- Workspaces (tags) 1-9
- Scratchpad

### Atalhos do Teclado

Para lista completa de atalhos do River WM, veja **[KEYBINDS.md](docs/KEYBINDS.md)**.

### Shell - Fish

- **Gerenciador de Plugins**: Fisher
- **Prompt**: Starship
- **Plugins**:
  - `autopair` - Fecha parênteses automaticamente
  - `sponge` - Remove comandos falhados do histórico
  - `fzf` - Fuzzy finder integrado
  - `sudope` - Adiciona sudo ao apertar ESC

**Aliases úteis:**

```bash
# Yay (pacman wrapper)
alias -- add-arch="yay -S --needed --noconfirm"
alias -- remove-arch="yay -Rns"
alias -- update-arch="flatpak update -y; and yay -Syu --noconfirm; and yay -c"
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

---

## 📦 Instalação

### Pré-requisitos

- Artix Linux instalado (Runit)
- Acesso root (sudo)
- Conexão com internet

### Instalação Completa

```bash
# 1. Clone o repositório
git clone git@github.com:EvertonDev2002/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Execute o script de instalação principal
chmod +x install.sh
./install.sh
```

O script `install.sh` irá:

1. ✅ Configurar repositório extra do Arch
2. ✅ Instalar Yay (AUR helper)
3. ✅ Instalar pacotes do sistema (pkglist.txt)
4. ✅ Instalar Flatpaks (flatpaklist.txt)
5. ✅ Copiar arquivos de sistema (/etc)
6. ✅ Habilitar serviços Runit
7. ✅ Criar symlinks com GNU Stow
8. ✅ Configurar usuário (grupos e sudo)
9. ✅ Configurar Firefox
10. ✅ Instalar temas e shell

### Instalação Modular

Você pode executar scripts individuais:

```bash
# Exemplo
./scripts/setup_dotfiles.sh
```

### Instalação Manual (Stow)

```bash
# Exemplo
# Instalar configurações específicas
cd ~/dotfiles
stow -d config -t ~ river
```

---

## �🔧 Scripts de Configuração

### Scripts de Setup (`scripts/`)

| Script              | Função                                      |
| ------------------- | ------------------------------------------- |
| `setup_repos.sh`    | Configura repos Artix/Arch + pacman.conf    |
| `setup_yay.sh`      | Instala Yay (AUR helper)                    |
| `setup_packages.sh` | Instala ~103 pacotes (Pacman + AUR)         |
| `setup_flatpaks.sh` | Instala Flatpak + Flathub + 29 apps         |
| `setup_system.sh`   | Copia configs de /etc com backup            |
| `setup_services.sh` | Habilita 17 serviços Runit                  |
| `setup_dotfiles.sh` | Aplica symlinks com GNU Stow                |
| `setup_user.sh`     | Configura sudo e grupos                     |
| `setup_firefox.sh`  | Detecta perfil e aplica user.js             |
| `setup_themes_plugins.sh`   | Instala Colloid + Plugins Fish (interativo) |

### Scripts de Inicialização (`config/scripts/.local/bin/`)

Todos os scripts possuem:

- ✅ Logging em `~/.local/state/init-log/`
- ✅ Error handling (`set -euo pipefail`)
- ✅ Paths dinâmicos com `$SCRIPT_DIR`

| Script              | Função                                      |
| ------------------- | ------------------------------------------- |
| `init-services.sh`  | Orquestra todos os serviços de usuário      |
| `init-pipewire.sh`  | Inicia stack de áudio PipeWire              |
| `init-portals.sh`   | XDG Desktop Portals (wlr + generic)         |
| `init-clipboard.sh` | Clipboard manager (wl-clipboard + cliphist) |
| `init-autostart.sh` | UI components (waybar, mako, wallpaper)     |
| `screenshot.sh`     | Captura de tela (grim + slurp)              |
| `powermenu.sh`      | Menu de energia (fuzzel)                    |
| `mirror_toggle.sh`  | Toggle espelhamento de display              |
| `set-wallpaper.sh`  | Gerencia wallpapers com swww                |

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

### Aliases do Fish

Editar: `config/fish/.config/fish/aliases.fish`

Recarregar:

```bash
source ~/.config/fish/aliases.fish
```

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
2. Crie uma Branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Add: Minha feature'`)
4. Push para a Branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request
