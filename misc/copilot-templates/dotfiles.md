# Instruções - Dotfiles Linux

## Contexto do Projeto

Este é um repositório de dotfiles para Arch Linux com foco em Wayland compositors (River) e ferramentas modernas.

## Notas Importantes

- Este é um projeto **pessoal** - priorize praticidade sobre perfeição
- Mantenha compatibilidade com Arch Linux
- Documente decisões não óbvias
- Backups são essenciais antes de modificar configurações do sistema
- Sempre teste mudanças em ambiente seguro quando possível

## Convenções Específicas do Projeto

### Estrutura de Diretórios

- `config/`: dotfiles organizados por aplicação
- `scripts/`: scripts de instalação e configuração modulares
- `scripts/lib/`: funções comuns reutilizáveis
- `system/`: arquivos de configuração do sistema
- `system/example/`: exemplos de configurações sensíveis/voláteis
- `pkgs/`: listas de pacotes
- `docs/`: documentação do projeto
- `misc/`: configurações diversas (browser, templates, etc.)

### Gerenciamento de Configurações do Sistema

- **Toda configuração de sistema deve estar presente na pasta `system/`**
- **Configurações sensíveis ou voláteis** (que podem mudar de acordo com a instalação):
  - Devem ter uma cópia de exemplo em `system/example/`
  - Exemplos: credenciais, paths específicos de máquina, configurações de rede
  - Use sufixo `.example` ou `.template` para arquivos de exemplo
  - Documente no README quais arquivos precisam ser copiados/modificados

**Exemplo de estrutura:**

```
system/
├── etc/
│   ├── nanorc
│   └── greetd/
│       └── config.toml
├── example/
│   ├── fstab.example
│   └── limine.conf.example
```

### Scripts de Setup

- Todos os scripts de setup devem:
  - Importar `scripts/lib/common.sh` para funções compartilhadas
  - Usar funções de log colorido (`log_info`, `log_success`, `log_error`)
  - Ser idempotentes (podem ser executados múltiplas vezes)
  - Validar pré-requisitos antes de executar
  - Criar backups antes de modificar arquivos existentes
  - **Ser autossuficientes**: devem funcionar quando executados diretamente pelo usuário OU chamados por outros scripts
  - **Carregar config.sh**: sempre carregar configurações centralizadas no início

### Gerenciamento de Logs

- **Localização**: todos os logs em `~/.local/state/init-log/` (ou `$DIR_LOG` do config.sh)
- **Truncamento automático**: use `exec >` para limpar log anterior (exceto River init)
- **River init específico**: precisa `rm -f` + `exec >>` para manter ordem correta dos logs
- **Scripts normais**: use `exec >` para truncar automaticamente
- **Detecção de contexto**: biblioteca `logging.sh` detecta terminal vs arquivo para cores ANSI
- **Proteção contra reload**: use guard `LOGGING_LIB_LOADED` para evitar redefinir variáveis readonly
- **Scripts em background**: executar diretamente (não via wrapper) para logs funcionarem

**Exemplo de logging correto:**

```bash
# Scripts normais (init-services.sh, init-autostart.sh, etc)
exec > "$DIR_LOG/services.log" 2>&1

# River init (comportamento especial)
rm -f "$DIR_LOG/river.log"
exec >> "$DIR_LOG/river.log" 2>&1

# Biblioteca de logging com proteção
if [ -n "${LOGGING_LIB_LOADED:-}" ]; then
    return 0
fi
readonly LOGGING_LIB_LOADED=1
```

### Gerenciamento de Pacotes

- Use `yay` para pacotes AUR
- Use `flatpak` para aplicações GUI quando disponível
- Mantenha listas de pacotes atualizadas em `pkgs/`
- Mantenha `README.md` atualizado em relação ao repositório
- Sempre verifique se pacote já está instalado antes de tentar instalar

### Wayland/Compositors

- Priorize compatibilidade com River, Sway e Hyprland
- Use `wl-clipboard` ao invés de `xclip`
- Prefira ferramentas nativas Wayland
- Sempre teste configurações em ambiente Wayland

### River Compositor - Configurações Específicas

**Estrutura de arquivos:**

- `config/river/.config/river/config.sh` - variáveis centralizadas
- `config/river/.config/river/init` - script principal do River
- Scripts init carregam `config.sh` para acessar variáveis

**Sintaxe riverctl (consulte [documentação oficial](https://man.archlinux.org/man/riverctl.1.en)):**

```bash
# Keyboard layout: FLAGS VÊM ANTES do layout
riverctl keyboard-layout -model abnt2 br  # ✓ CORRETO
riverctl keyboard-layout br -model abnt2  # ✗ ERRADO (error: too many arguments)

# Input: valores devem ser completos, não abreviados
riverctl input "$TOUCHPAD_ID" tap-button-map left-right-middle  # ✓ CORRETO
riverctl input "$TOUCHPAD_ID" tap-button-map lrm                # ✗ ERRADO (error: unknown option)

# Teclas de mídia: evite loops, defina explicitamente para cada modo
# ✗ ERRADO - causa "error: too many arguments"
for mode in normal locked; do
    riverctl map $mode None XF86AudioMute spawn 'pactl ...'
done

# ✓ CORRETO - comandos explícitos
riverctl map normal None XF86AudioMute spawn 'pactl ...'
riverctl map locked None XF86AudioMute spawn 'pactl ...'
```

**Boas práticas River:**

- Sempre consulte `man riverctl` para sintaxe correta
- Flags opcionais (`-model`, `-variant`, `-options`) vêm ANTES de argumentos posicionais
- Valores de opções devem ser completos (ex: `left-right-middle`, não `lrm`)
- Scripts init executados em background (`&`) para não bloquear
- Warnings `overwrote an existing keybinding` são normais durante reload

### Documentação

- **Toda documentação do repositório deve ser criada em `docs/`**
- **Nomenclatura**: use nomes descritivos que indicam claramente o conteúdo
  - Exemplos: `KEYBINDS.md`, `SYSTEM-CONFIG.md`, `TROUBLESHOOTING.md`
- **Cabeçalho obrigatório**: todo documento deve começar com:

  - Título claro indicando seu propósito
  - Subtítulo ou nota indicando o diretório/módulo ao qual se refere
  - Exemplos:

    ```markdown
    # Atalhos do River WM

    > Documentação de configurações em `config/river/`

    # Configurações do Sistema

    > Arquivos de sistema em `system/etc/`
    ```

- **Mantenha o `README.md` e arquivos em `docs/` atualizados** sempre que adicionar ou modificar:
  - Novos scripts ou funcionalidades
  - Dependências ou pacotes necessários
  - Estrutura de diretórios
  - Processos de instalação ou configuração
  - Troubleshooting ou problemas conhecidos
- Documente decisões de design ou escolhas técnicas não óbvias
- Atualize screenshots ou exemplos quando a interface/saída mudar
- **Referências cruzadas**: sempre referencie outros documentos quando relevante
  - Exemplo: "Para mais detalhes sobre River, veja [docs/KEYBINDS.md](docs/KEYBINDS.md)"

## Ferramentas Específicas

### Preferências

- **Terminal**: Kitty, Foot, Alacritty
- **Shell**: Fish (interativo), Bash (scripts)
- **Editor**: VSCode/VSCodium, Nano
- **Compositor**: River
- **Bar**: Waybar
- **Launcher**: Fuzzel
- **Package Manager**: yay, flatpak

## Troubleshooting e Debugging

### Análise de Logs

**Localização dos logs:**

- River compositor: `~/.local/state/init-log/river.log`
- Services (audio, portals, clipboard): `~/.local/state/init-log/{services,audio,portals,clipboard}.log`
- Autostart (temas, waybar): `~/.local/state/init-log/autostart.log`
- Utils (wallpaper, screenshot): `~/.local/state/init-log/{wallpaper,screenshot}.log`

**Debug de scripts:**

```bash
# Modo debug temporário (adicionar após shebang)
set -x  # Mostra cada comando antes de executar

# Validar sintaxe sem executar
bash -n script.sh

# Executar script manualmente para debug
~/.local/bin/init/init-services.sh  # Roda independente do River
```

**Problemas comuns:**

1. **"error: too many arguments"** → Ordem incorreta de argumentos (flags devem vir antes)
2. **"error: unknown option"** → Valor abreviado ou inválido (use valor completo)
3. **Logs não aparecem** → Scripts executados via wrapper impedem `exec >` de funcionar
4. **Logs fora de ordem no River** → Use `rm -f` + `exec >>` ao invés de apenas `exec >`
5. **"variável permite somente leitura"** → Biblioteca carregada múltiplas vezes (adicione guard)
6. **Caracteres estranhos em logs** → Códigos ANSI sendo salvos (detecte terminal vs arquivo)

### Verificação de Processos

```bash
# Verificar se serviços estão rodando
pgrep -fa "pipewire|waybar|mako"

# Verificar variáveis do config.sh
bash -c '. ~/.config/river/config.sh && echo $TOUCHPAD_ID'

# Testar comando riverctl isoladamente
riverctl keyboard-layout -model abnt2 br  # Deve funcionar sem erros
```

## Referências Específicas

### Linux & Sistema

- [Arch Wiki](https://wiki.archlinux.org/)
- [Artix Linux Wiki](https://wiki.artixlinux.org/)
- [Runit Documentation](http://smarden.org/runit/)
- [Limine Bootloader](https://github.com/limine-bootloader/limine)
- [Limine Bootloader | Config](https://github.com/limine-bootloader/limine/blob/v10.x/CONFIG.md)
- [Limine Bootloader | Usage](https://github.com/limine-bootloader/limine/blob/v10.x/USAGE.md)
- [AppArmor Documentation](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)

### Wayland & Compositors

- [Wayland Documentation](https://wayland.freedesktop.org/)
- [River Documentation](https://codeberg.org/river/river/wiki)
- [River Man Page](https://man.archlinux.org/man/river.1.en)
- [riverctl Man Page](https://man.archlinux.org/man/extra/river/riverctl.1.en)
- [rivertile Man Page](https://man.archlinux.org/man/rivertile.1.en)
- [Sway Documentation](https://github.com/swaywm/sway/wiki)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Waybar Man Page](https://man.archlinux.org/man/waybar.5)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
