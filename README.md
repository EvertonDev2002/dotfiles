# 🏠 Dotfiles - Artix Linux + River WM

Configurações pessoais para Artix Linux (Runit) com River (Wayland compositor), otimizadas para performance, privacidade e produtividade.

![Artix Linux](https://img.shields.io/badge/Artix_Linux-Runit-10b981?style=for-the-badge&logo=artixlinux)
![River WM](https://img.shields.io/badge/River-Wayland-0ea5e9?style=for-the-badge)
![Fish Shell](https://img.shields.io/badge/Fish-Shell-f59e0b?style=for-the-badge&logo=fishshell)
![CI Status](https://img.shields.io/github/actions/workflow/status/EvertonDev2002/dotfiles/validate.yml?style=for-the-badge&label=Validações&logo=githubactions)
![Conventional Commits](https://img.shields.io/badge/Conventional_Commits-1.0.0-fe5196?style=for-the-badge&logo=conventionalcommits&logoColor=white)

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Screenshots](#-screenshots)
- [Características](#-características)
- [Componentes](#-componentes)
- [Instalação](#-instalação)
- [Scripts de Configuração](#-scripts-de-configuração)
- [Customização](#-customização)
- [Troubleshooting](#-troubleshooting)
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
- **Aliases modernos** (fd, ripgrep, eza, bat, rsync)
- **Pacman otimizado**

### 🔒 Privacidade & Segurança

- **Firefox hardened** com 170+ preferências comentadas
- **DNS-over-HTTPS** (Cloudflare + Google fallback)
- **NetworkManager** com MAC randomization (globalmente)
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
- **Configuração Principal**: `config/river/.config/river/init`
- **Variáveis Centralizadas**: `config/river/.config/river/config.sh`

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
alias cp="rsync -ah --progress"
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
# use * para linkar todos
cd ~/dotfiles/config
stow -t $HOME river
```

---

## 🔧 Scripts de Configuração

### Scripts de Setup (`scripts/setup/`)

| Script                    | Função                                      |
| ------------------------- | ------------------------------------------- |
| `setup_repos.sh`          | Configura repos Artix/Arch + pacman.conf    |
| `setup_yay.sh`            | Instala Yay (AUR helper)                    |
| `setup_packages.sh`       | Instala ~130 pacotes (Pacman + AUR)         |
| `setup_flatpaks.sh`       | Instala Flatpak + Flathub + 29 apps         |
| `setup_system.sh`         | Copia configs de /etc com backup            |
| `setup_services.sh`       | Habilita 17 serviços Runit                  |
| `setup_dotfiles.sh`       | Aplica symlinks com GNU Stow                |
| `setup_user.sh`           | Configura sudo e grupos                     |
| `setup_firefox.sh`        | Detecta perfil e aplica user.js             |
| `setup_themes_plugins.sh` | Instala Colloid + Plugins Fish (interativo) |

### Scripts de Inicialização (`config/scripts/.local/bin/`)

Todos os scripts possuem:

- ✅ Configuração centralizada via `config.sh` (variáveis, paths, IDs de hardware)
- ✅ Logging estruturado em `~/.local/state/init-log/`
- ✅ Error handling (`set -e` para Bash scripts)
- ✅ Autonomia (podem ser executados diretamente ou chamados por outros scripts)

| Script              | Função                                          |
| ------------------- | ----------------------------------------------- |
| `init-services.sh`  | Orquestra serviços (keyring, polkit, audio, UI) |
| `init-pipewire.sh`  | Stack de áudio (PipeWire + WirePlumber)         |
| `init-portals.sh`   | XDG Desktop Portals (wlr + gtk + generic)       |
| `init-clipboard.sh` | Clipboard manager (wl-paste + cliphist)         |
| `init-autostart.sh` | UI/Temas (GTK, waybar, mako, wallpaper)         |
| `screenshot.sh`     | Captura de tela (grim + slurp + notificação)    |
| `powermenu.sh`      | Menu de sessão (fuzzel: shutdown/reboot/logout) |
| `mirror_toggle.sh`  | Espelhamento de displays (wl-mirror)            |
| `set-wallpaper.sh`  | Wallpapers aleatórios ou específicos (swww)     |

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

## � Troubleshooting

**Problemas comuns e soluções rápidas:**

```bash
# River não inicia
cat ~/.local/state/init-log/river.log
chmod +x ~/.config/river/init

# Waybar não aparece
killall waybar && waybar &
cat ~/.local/state/init-log/autostart.log

# Som não funciona
~/.local/bin/init/init-pipewire.sh
pgrep -fa "pipewire|wireplumber"

# Ver todos os logs
tail -f ~/.local/state/init-log/*.log
grep -i error ~/.local/state/init-log/*.log
```

**📚 Documentação Completa:**

### Documentação do Projeto

- **[TROUBLESHOOTING](docs/TROUBLESHOOTING.md)** — Solução de problemas detalhada e logs
- **[KEYBINDS](docs/KEYBINDS.md)** — Atalhos do River WM
- **[SYSTEM-CONFIG](docs/SYSTEM-CONFIG.md)** — Configurações do sistema
- **[ACTIONS](docs/ACTIONS.md)** — CI/CD e validações automáticas

### Documentação de Terceiros e Referências

- **[Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0)** — Padrão de mensagens de commit
- **[Betterfox](https://github.com/yokoffing/Betterfox)** — Hardening do Firefox
- **[River Documentation](https://codeberg.org/river/river/wiki)** — Documentação oficial do River WM
- **[Arch Wiki](https://wiki.archlinux.org/)** — Referência para Arch/Artix Linux
- **[Wayland Documentation](https://wayland.freedesktop.org/)** — Documentação oficial do Wayland
- **[Limine Bootloader](https://github.com/limine-bootloader/limine)** — Bootloader utilizado
- **[Spotify Player](https://github.com/aome510/spotify-player)** — Player de Spotify no terminal (TUI), rápido, leve e com suporte a playlists, busca e atalhos de teclado.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Se você encontrou um bug ou tem uma sugestão:

1. Abra uma Issue
2. Crie uma Branch (`git checkout -b feature/MinhaFeature`)
3. Commit com **Conventional Commits** (`feat:`, `fix:`, `docs:`, etc.)
4. Aguarde validações do CI passarem
5. Push para a Branch (`git push origin feature/MinhaFeature`)
6. Abra um Pull Request

**Validações locais:**

```bash
shellcheck scripts/setup/*.sh  # Análise estática
bash -n scripts/setup/*.sh     # Verificar sintaxe
```

> **Nota:** Use a extensão ShellCheck do VS Code para análise em tempo real durante a edição.
