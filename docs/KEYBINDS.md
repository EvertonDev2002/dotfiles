# ⌨️ Niri - Atalhos de Teclado

> Documentação de configurações em `config/niri/.config/niri/modules/70-binds.kdl`

## 🚀 Aplicações

| Tecla       | Descrição                                |
| ----------- | ---------------------------------------- |
| `Super + T` | Abrir terminal (Kitty)                   |
| `Super + N` | Abrir navegador (Firefox)                |
| `Super + E` | Abrir gerenciador de arquivos (Nautilus) |
| `Super + M` | Abrir launcher (Fuzzel)                  |
| `Super + D` | Abrir editor de código (VSCode)          |
| `Super + P` | Toggle espelhamento de tela              |

## 🪟 Gerenciamento de Janelas

### Foco (Navegação entre Janelas)

| Tecla                      | Descrição                |
| -------------------------- | ------------------------ |
| `Super + H` ou `Super + ←` | Focar coluna à esquerda  |
| `Super + J` ou `Super + ↓` | Focar janela abaixo      |
| `Super + K` ou `Super + ↑` | Focar janela acima       |
| `Super + L` ou `Super + →` | Focar coluna à direita   |
| `Super + Home`             | Focar primeira coluna    |
| `Super + End`              | Focar última coluna      |

### Mover Janelas

| Tecla                           | Descrição                           |
| ------------------------------- | ----------------------------------- |
| `Super + Ctrl + H` ou `Ctrl + ←` | Mover coluna para esquerda          |
| `Super + Ctrl + J` ou `Ctrl + ↓` | Mover janela para baixo na coluna   |
| `Super + Ctrl + K` ou `Ctrl + ↑` | Mover janela para cima na coluna    |
| `Super + Ctrl + L` ou `Ctrl + →` | Mover coluna para direita           |
| `Super + Ctrl + Home`            | Mover coluna para primeira posição  |
| `Super + Ctrl + End`             | Mover coluna para última posição    |

### Estados e Modos

| Tecla               | Descrição                        |
| ------------------- | -------------------------------- |
| `Super + Q`         | Fechar janela atual              |
| `Super + F`         | Maximizar coluna                 |
| `Super + Shift + F` | Toggle tela cheia (fullscreen)   |
| `Super + V`         | Toggle janela flutuante          |
| `Super + Shift + V` | Alternar foco: flutuante/tiling  |
| `Super + W`         | Toggle modo com abas na coluna   |

### Organização de Colunas

| Tecla                  | Descrição                                     |
| ---------------------- | --------------------------------------------- |
| `Super + [`            | Consumir/expelir janela da esquerda           |
| `Super + ]`            | Consumir/expelir janela da direita            |
| `Super + ,`            | Consumir janela da direita para coluna atual  |
| `Super + .`            | Expelir janela inferior da coluna para direita|
| `Super + C`            | Centralizar coluna                            |
| `Super + Ctrl + C`     | Centralizar todas as colunas visíveis         |

### Dimensões (Largura/Altura)

| Tecla                   | Descrição                            |
| ----------------------- | ------------------------------------ |
| `Super + R`             | Alternar entre presets de largura    |
| `Super + Shift + R`     | Alternar entre presets de altura     |
| `Super + Ctrl + R`      | Resetar altura da janela             |
| `Super + Ctrl + F`      | Expandir coluna para largura livre   |
| `Super + -`             | Diminuir largura da coluna (-10%)    |
| `Super + =`             | Aumentar largura da coluna (+10%)    |
| `Super + Shift + -`     | Diminuir altura da janela (-10%)     |
| `Super + Shift + =`     | Aumentar altura da janela (+10%)     |

## 🖥️ Monitores

### Focar Monitores

| Tecla                           | Descrição               |
| ------------------------------- | ----------------------- |
| `Super + Shift + H` ou `Shift + ←` | Focar monitor à esquerda |
| `Super + Shift + J` ou `Shift + ↓` | Focar monitor abaixo     |
| `Super + Shift + K` ou `Shift + ↑` | Focar monitor acima      |
| `Super + Shift + L` ou `Shift + →` | Focar monitor à direita  |

### Mover Janelas entre Monitores

| Tecla                                      | Descrição                               |
| ------------------------------------------ | --------------------------------------- |
| `Super + Shift + Ctrl + H` ou `Shift + Ctrl + ←` | Mover coluna para monitor à esquerda    |
| `Super + Shift + Ctrl + J` ou `Shift + Ctrl + ↓` | Mover coluna para monitor abaixo        |
| `Super + Shift + Ctrl + K` ou `Shift + Ctrl + ↑` | Mover coluna para monitor acima         |
| `Super + Shift + Ctrl + L` ou `Shift + Ctrl + →` | Mover coluna para monitor à direita     |

## 🏷️ Workspaces

### Navegação

| Tecla                     | Descrição                           |
| ------------------------- | ----------------------------------- |
| `Super + 1-9`             | Ir para workspace 1-9               |
| `Super + U`               | Ir para workspace anterior          |
| `Super + I`               | Ir para próximo workspace           |
| `Super + Page Down`       | Ir para workspace anterior          |
| `Super + Page Up`         | Ir para próximo workspace           |
| `Super + O`               | Toggle Overview (visão geral)       |

### Mover Janelas entre Workspaces

| Tecla                       | Descrição                              |
| --------------------------- | -------------------------------------- |
| `Super + Ctrl + 1-9`        | Mover coluna para workspace 1-9        |
| `Super + Ctrl + U`          | Mover coluna para workspace anterior   |
| `Super + Ctrl + I`          | Mover coluna para próximo workspace    |
| `Super + Ctrl + Page Down`  | Mover coluna para workspace anterior   |
| `Super + Ctrl + Page Up`    | Mover coluna para próximo workspace    |

### Mover Workspaces

| Tecla                     | Descrição                           |
| ------------------------- | ----------------------------------- |
| `Super + Shift + U`       | Mover workspace para baixo          |
| `Super + Shift + I`       | Mover workspace para cima           |
| `Super + Shift + Page Down` | Mover workspace para baixo        |
| `Super + Shift + Page Up`   | Mover workspace para cima         |

## 🖱️ Mouse e Touchpad

### Scroll do Mouse (com Super)

| Ação                                 | Descrição                            |
| ------------------------------------ | ------------------------------------ |
| `Super + Scroll ↓` (cooldown 150ms)  | Ir para workspace anterior           |
| `Super + Scroll ↑` (cooldown 150ms)  | Ir para próximo workspace            |
| `Super + Scroll →`                   | Focar coluna à direita               |
| `Super + Scroll ←`                   | Focar coluna à esquerda              |
| `Super + Ctrl + Scroll ↓`            | Mover coluna para workspace anterior |
| `Super + Ctrl + Scroll ↑`            | Mover coluna para próximo workspace  |
| `Super + Ctrl + Scroll →`            | Mover coluna para direita            |
| `Super + Ctrl + Scroll ←`            | Mover coluna para esquerda           |
| `Super + Shift + Scroll ↓`           | Focar coluna à direita               |
| `Super + Shift + Scroll ↑`           | Focar coluna à esquerda              |

### Gestos do Touchpad

| Gesto                  | Descrição                |
| ---------------------- | ------------------------ |
| Deslize 4 dedos para cima | Abrir Overview           |
| Mover mouse para canto superior esquerdo | Abrir Overview |

## ⚙️ Sistema

| Tecla               | Descrição                              |
| ------------------- | -------------------------------------- |
| `Super + Shift + C` | Recarregar configuração do Niri        |
| `Super + Esc`       | Toggle Waybar (matar/reiniciar)        |

## 📸 Capturas de Tela

| Tecla         | Descrição                              |
| ------------- | -------------------------------------- |
| `Print`       | Screenshot (área selecionada)          |
| `Ctrl + Print`| Screenshot da tela completa            |
| `Alt + Print` | Screenshot da janela ativa             |

## 🔊 Mídia e Volume

**Nota:** Atalhos de mídia funcionam mesmo com a tela bloqueada (`allow-when-locked=true`)

### Áudio

| Tecla                | Descrição                     |
| -------------------- | ----------------------------- |
| `Fn + ▲ Vol` (XF86AudioRaiseVolume) | Aumentar volume (+10%, máx 100%) |
| `Fn + ▼ Vol` (XF86AudioLowerVolume) | Diminuir volume (-10%)        |
| `Fn + 󰝟 Mute` (XF86AudioMute)       | Mutar/desmutar áudio          |
| `Fn + ⊗ Mic` (XF86AudioMicMute)     | Mutar/desmutar microfone      |

### Controle de Mídia

| Tecla                    | Descrição                  |
| ------------------------ | -------------------------- |
| `Fn + ▶/❚❚` (XF86AudioPlay)  | Play/pause mídia           |
| `Fn + ■` (XF86AudioStop)      | Parar reprodução           |
| `Fn + ◀◀` (XF86AudioPrev)     | Faixa anterior             |
| `Fn + ▶▶` (XF86AudioNext)     | Próxima faixa              |

### Brilho

| Tecla                           | Descrição              |
| ------------------------------- | ---------------------- |
| `Fn + ☼ +` (XF86MonBrightnessUp)   | Aumentar brilho (+10%) |
| `Fn + ☼ −` (XF86MonBrightnessDown) | Diminuir brilho (-10%) |

---

## 📝 Notas

### Sistema de Colunas do Niri

O Niri usa um sistema de **colunas** ao invés do modelo tradicional de tiling:

- **Colunas**: grupos verticais que podem conter uma ou mais janelas empilhadas
- **Janelas**: dentro de cada coluna, janelas são empilhadas verticalmente
- **Navegação horizontal**: move entre colunas
- **Navegação vertical**: move entre janelas dentro da mesma coluna

### Comandos Alternativos (Comentados)

Alguns comandos alternativos estão disponíveis mas comentados na configuração:

- **Alternar layouts de teclado**: `Super + Space` e `Super + Shift + Space` (conflita com xkb)
- **Focar ou mudar workspace**: `Super + J/K` pode focar janela OU mudar workspace ao atingir limite
- **Alternar para workspace anterior**: `Super + Tab` (alternativa para `Super + U/I`)
- **Mover apenas janela** (não coluna inteira): variantes de comandos de movimento
- **Controle de volume via touchpad**: scroll com `Super` no touchpad

### Overview (Visão Geral)

O **Overview** (`Super + O`) mostra uma visão ampliada de todos os workspaces e janelas, facilitando navegação visual. Também pode ser ativado por:
- Gesto de 4 dedos para cima no touchpad
- Movendo o mouse para o canto superior esquerdo da tela

### Workspaces Dinâmicos

O Niri usa workspaces dinâmicos:
- Sempre há um workspace vazio disponível no final
- Referenciar índices maiores que o número atual sempre aponta para o último workspace
- Exemplo: com 2 workspaces + 1 vazio, `Super + 5` vai para o 3º workspace

### Ferramentas Utilizadas

- **wpctl**: controle de volume (PipeWire)
- **playerctl**: controle de mídia (MPRIS)
- **brightnessctl**: controle de brilho
- **mirror-toggle.sh**: script customizado para espelhamento de tela

---

**Para mais informações**, consulte:
- [Documentação oficial do Niri](https://yalter.github.io/niri/Configuration%3A-Introduction.html)
- [Arquivo de configuração](../config/niri/.config/niri/modules/70-binds.kdl)
