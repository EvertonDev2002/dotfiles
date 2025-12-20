# ⌨️ River WM - Atalhos de Teclado

## 🚀 Aplicações

| Tecla       | Descrição                                |
| ----------- | ---------------------------------------- |
| `Super + T` | Abrir terminal (Foot)                    |
| `Super + N` | Abrir navegador (Firefox)                |
| `Super + E` | Abrir gerenciador de arquivos (Nautilus) |
| `Super + M` | Abrir launcher (Fuzzel)                  |
| `Super + D` | Abrir editor de código (VSCode)          |
| `Super + P` | Toggle espelhamento de tela (wl-mirror)  |

## 🪟 Gerenciamento de Janelas

### Foco (Navegação)

| Tecla                      | Descrição               |
| -------------------------- | ----------------------- |
| `Super + H` ou `Super + ←` | Focar janela à esquerda |
| `Super + J` ou `Super + ↓` | Focar janela abaixo     |
| `Super + K` ou `Super + ↑` | Focar janela acima      |
| `Super + L` ou `Super + →` | Focar janela à direita  |

### Mover Janelas (Swap)

| Tecla                                      | Descrição                   |
| ------------------------------------------ | --------------------------- |
| `Super + Shift + H`                        | Trocar janela para esquerda |
| `Super + Shift + J` ou `Super + Shift + ↓` | Trocar janela para baixo    |
| `Super + Shift + K` ou `Super + Shift + ↑` | Trocar janela para cima     |
| `Super + Shift + L`                        | Trocar janela para direita  |

### Estados e Layout

| Tecla               | Descrição                          |
| ------------------- | ---------------------------------- |
| `Super + Return`    | Zoom (promover janela para mestre) |
| `Super + F`         | Toggle janela flutuante            |
| `Super + Shift + F` | Toggle tela cheia                  |
| `Super + Q`         | Fechar janela atual                |

### Rivertile (Ajustes de Layout)

| Tecla                   | Descrição                                    |
| ----------------------- | -------------------------------------------- |
| `Super + Space`         | Diminuir proporção da área principal (-0.05) |
| `Super + Shift + Space` | Aumentar proporção da área principal (+0.05) |
| `Super + Ctrl + H`      | Aumentar número de janelas principais        |
| `Super + Ctrl + L`      | Diminuir número de janelas principais        |

## 🖥️ Monitores

| Tecla               | Descrição                             |
| ------------------- | ------------------------------------- |
| `Super + [`         | Focar monitor à esquerda              |
| `Super + ]`         | Focar monitor à direita               |
| `Super + Shift + [` | Enviar janela para monitor à esquerda |
| `Super + Shift + ]` | Enviar janela para monitor à direita  |

## 🏷️ Tags (Workspaces)

| Tecla                        | Descrição                          |
| ---------------------------- | ---------------------------------- |
| `Super + 1-9`                | Mudar para tag 1-9                 |
| `Super + Shift + 1-9`        | Mover janela para tag 1-9          |
| `Super + Ctrl + 1-9`         | Visualizar tag 1-9 junto com atual |
| `Super + Shift + Ctrl + 1-9` | Fixar janela em múltiplas tags     |
| `Super + 0`                  | Visualizar todas as tags           |

## 🖱️ Mouse

| Tecla                    | Descrição               |
| ------------------------ | ----------------------- |
| `Super + Botão Esquerdo` | Mover janela            |
| `Super + Botão Direito`  | Redimensionar janela    |
| `Super + Botão do Meio`  | Toggle janela flutuante |

## ⚙️ Sistema

| Tecla               | Descrição                                        |
| ------------------- | ------------------------------------------------ |
| `Super + Shift + C` | Recarregar configuração do River                 |
| `Super + Esc`       | Toggle Waybar (matar/iniciar)                    |
| `Print Screen`      | Captura de tela                                  |
| `Super + F11`       | Entrar/Sair do modo passthrough (para VMs/jogos) |

## 🔊 Mídia (Funcionam mesmo com tela bloqueada)

| Tecla          | Descrição                |
| ---------------------- | ------------------------ |
| `Fn + F3` ou `▲ Vol`   | Aumentar volume (+5%)    |
| `Fn + F2` ou `▼ Vol`   | Diminuir volume (-5%)    |
| `Fn + F1` ou `󰝟 Mute` | Mutar/desmutar áudio     |
| `Fn + F4` ou `⊗ Mic`   | Mutar/desmutar microfone |
| `Fn + F6` ou `☼ +`     | Aumentar brilho (+5%)    |
| `Fn + F5` ou `☼ −`     | Diminuir brilho (-5%)    |
| `Fn + F8` ou `▶/❚❚`    | Play/pause mídia         |
| `Fn + F10` ou `▶▶`     | Próxima faixa            |
| `Fn + F9` ou `◀◀`      | Faixa anterior           |

---

## 📝 Notas

- **Modo Passthrough**: Usado quando você precisa que todos os atalhos sejam enviados diretamente para a aplicação (útil em VMs ou jogos). Pressione `Super + F11` para ativar/desativar.
- **Tags vs Workspaces**: No River, tags são mais flexíveis que workspaces tradicionais - uma janela pode estar em múltiplas tags simultaneamente.
- **Rivertile**: Layout padrão do River. A "área principal" é onde ficam as janelas mais importantes, e você pode ajustar quantas janelas ficam nessa área.
