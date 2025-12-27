# Troubleshooting e Logs

> Documentação de solução de problemas e gerenciamento de logs do sistema

## 📝 Logs do Sistema

Todos os logs de inicialização e serviços ficam em `~/.local/state/init-log/`:

### Arquivos de Log Disponíveis

| Arquivo          | Descrição                                   |
| ---------------- | ------------------------------------------- |
| `river.log`      | Compositor River (erros riverctl, init)     |
| `services.log`   | Orquestração de serviços                    |
| `audio.log`      | Stack PipeWire (pipewire, wireplumber)      |
| `portals.log`    | XDG Desktop Portals                         |
| `clipboard.log`  | Clipboard manager (wl-clipboard + cliphist) |
| `autostart.log`  | UI components (waybar, mako, wallpaper)     |
| `wallpaper.log`  | Gerenciamento de wallpapers                 |
| `screenshot.log` | Capturas de tela                            |

### Comandos Úteis para Logs

```bash
# Ver logs em tempo real
tail -f ~/.local/state/init-log/services.log

# Verificar erros específicos
grep -i error ~/.local/state/init-log/*.log

# Listar todos os logs
ls -lh ~/.local/state/init-log/

# Ver últimas 50 linhas de um log
tail -n 50 ~/.local/state/init-log/river.log

# Verificar warnings
grep -i warning ~/.local/state/init-log/*.log
```

**󰋗 Nota:** Logs são automaticamente truncados a cada reload do River (exceto `river.log` que usa append).

---

## 🔧 Troubleshooting

### River não inicia

```bash
# Verificar log de erros
cat ~/.local/state/init-log/river.log

# Verificar permissões
chmod +x ~/.config/river/init

# Testar riverctl manualmente
riverctl keyboard-layout -model abnt2 br

# Verificar se config.sh está carregando
bash -c '. ~/.config/river/config.sh && echo $TOUCHPAD_ID'
```

### Waybar não aparece

```bash
# Verificar log de autostart
cat ~/.local/state/init-log/autostart.log

# Reiniciar waybar
killall waybar && waybar &

# Verificar se processo está rodando
pgrep -fa waybar

# Testar waybar manualmente
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

### Som não funciona

```bash
# Verificar stack PipeWire
cat ~/.local/state/init-log/audio.log

# Reiniciar serviços de áudio
~/.local/bin/init/init-pipewire.sh

# Verificar processos de áudio
pgrep -fa "pipewire|wireplumber"

# Listar devices de áudio
pactl list sinks short
wpctl status

# Testar reprodução
paplay /usr/share/sounds/freedesktop/stereo/bell.oga
```

### Erros comuns do riverctl

```bash
# "error: too many arguments" → flags devem vir antes dos argumentos posicionais
riverctl keyboard-layout -model abnt2 br  # ✓ Correto
riverctl keyboard-layout br -model abnt2  # ✗ Errado

# "error: unknown option" → use nomes completos, não abreviações
riverctl input <id> tap-button-map left-right-middle  # ✓ Correto
riverctl input <id> tap-button-map lrm                # ✗ Errado

# Verificar sintaxe do riverctl
man riverctl
riverctl -h
```

### Logs não aparecem

```bash
# Executar script manualmente para debug
~/.local/bin/init/init-services.sh

# Verificar se diretório de logs existe
ls -la ~/.local/state/init-log/

# Criar diretório se não existir
mkdir -p ~/.local/state/init-log

# Recarregar River (Super+Shift+C)
# Logs devem ser recriados automaticamente
```

### Problemas com Touchpad

```bash
# Verificar ID do touchpad
riverctl list-inputs

# Testar configuração do touchpad
riverctl input <touchpad-id> tap enabled
riverctl input <touchpad-id> natural-scroll enabled

# Ver configuração atual
cat ~/.config/river/config.sh | grep TOUCHPAD
```

### Clipboard não funciona

```bash
# Verificar logs
cat ~/.local/state/init-log/clipboard.log

# Verificar processos
pgrep -fa "wl-paste|cliphist"

# Reiniciar clipboard manager
killall wl-paste
~/.local/bin/init/init-clipboard.sh

# Testar clipboard
echo "teste" | wl-copy
wl-paste
```

### Notificações (Mako) não aparecem

```bash
# Verificar se mako está rodando
pgrep -fa mako

# Reiniciar mako
killall mako && mako &

# Testar notificação
notify-send "Teste" "Notificação de teste"

# Ver log do mako
journalctl --user -u mako -f
```

### Wallpaper não carrega

```bash
# Verificar log
cat ~/.local/state/init-log/wallpaper.log

# Verificar se swww está rodando
pgrep -fa swww

# Reiniciar swww daemon
killall swww
swww-daemon &

# Testar wallpaper manualmente
~/.local/bin/set-wallpaper.sh
```

### Display/Monitor não detectado

```bash
# Listar outputs disponíveis
wlr-randr

# Verificar configuração way-displays
way-displays -g  # Gerar configuração

# Logs do way-displays
journalctl --user -u way-displays -f
```

---

## 🛡️ Backups Automáticos

Os scripts de setup criam backups automáticos antes de modificar arquivos de sistema:

### Localização dos Backups

```bash
# Backups de /etc
/etc/dotfiles-backup-YYYY-MM-DD_HH-MM-SS/

# Backup do pacman.conf
/etc/pacman.conf.backup-YYYY-MM-DD_HH-MM-SS

# Verificar backups
ls -lh /etc/ | grep backup
```

### Restaurar Backups

```bash
# Exemplo: restaurar pacman.conf
sudo cp /etc/pacman.conf.backup-2025-12-26_14-30-00 /etc/pacman.conf

# Exemplo: restaurar diretório /etc completo
sudo cp -r /etc/dotfiles-backup-2025-12-26_14-30-00/* /etc/
```

---

## 🔍 Debug Avançado

### Modo Debug em Scripts

Adicione debug temporário em scripts Bash:

```bash
# Adicionar após shebang
set -x  # Mostra cada comando antes de executar

# Validar sintaxe sem executar
bash -n script.sh

# Executar com trace
bash -x script.sh
```

### Verificar Processos

```bash
# Verificar se serviços essenciais estão rodando
pgrep -fa "river|waybar|mako|pipewire"

# Ver árvore de processos do River
pstree -p $(pgrep river)

# Monitorar recursos
htop
```

### Testar Componentes Isoladamente

```bash
# Testar PipeWire
pipewire &
wireplumber &

# Testar portals
/usr/libexec/xdg-desktop-portal-wlr &
/usr/libexec/xdg-desktop-portal-gtk &

# Testar waybar
waybar -l debug

# Testar mako
mako -c ~/.config/mako/config
```

---

## 📚 Documentação Relacionada

- **[KEYBINDS.md](KEYBINDS.md)** - Atalhos do River WM
- **[SYSTEM-CONFIG.md](SYSTEM-CONFIG.md)** - Configurações do sistema
- **[COPILOT-TEMPLATES.md](COPILOT-TEMPLATES.md)** - Templates e padrões de código
- **[README.md](../README.md)** - Documentação principal

---

## 💡 Dicas Úteis

### Performance

```bash
# Verificar tempo de boot
systemd-analyze  # Se systemd estiver instalado

# Verificar uso de memória
free -h
htop

# Limpar cache do pacman
yay -Sc

# Limpar cache do Flatpak
flatpak uninstall --unused
```

### Manutenção

```bash
# Atualizar sistema completo
update-arch  # Alias configurado

# Verificar pacotes órfãos
yay -Qtdq

# Remover pacotes órfãos
yay -Qtdq | yay -Rns -

# Verificar integridade de arquivos
sudo pacman -Qkk
```

### Personalização

```bash
# Recarregar configurações do River
Super + Shift + C

# Recarregar Fish shell
source ~/.config/fish/config.fish

# Recarregar Waybar
killall waybar && waybar &

# Trocar wallpaper
Super + W  # Ou ~/.local/bin/set-wallpaper.sh
```
