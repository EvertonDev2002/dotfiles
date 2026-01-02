# Configuração Modular do Niri

Esta configuração do Niri usa uma estrutura modular para melhor manutenibilidade.

## Estrutura

```
.config/niri/
├── config.kdl           # Arquivo gerado (NÃO editar diretamente!)
├── config.kdl._bak      # Backup automático
├── README.md            # Esta documentação
├── build/
│   └── build-config.sh  # Script para gerar config.kdl
├── modules/             # Módulos editáveis da configuração
│   ├── 00-header.kdl
│   ├── 10-input.kdl
│   ├── 20-output.kdl
│   ├── 30-layout.kdl
│   ├── 40-spawn.kdl
│   ├── 50-animations.kdl
│   ├── 60-window-rules.kdl
│   └── 70-binds.kdl
├── session/
│   └── niri-session.sh  # Script de inicialização da sessão Niri
└── variables/
    └── config.sh        # Variáveis de configuração centralizadas
```

## Módulos

### 00-header.kdl

Comentários iniciais e introdução do arquivo KDL.

### 10-input.kdl

Configurações de dispositivos de entrada:

- Teclado (layout, numlock)
- Touchpad (tap, natural-scroll, etc.)
- Mouse
- Trackpoint
- Focus-follows-mouse

### 20-output.kdl

Configurações de monitores:

- Resolução e taxa de atualização
- Escala e rotação
- Posicionamento no espaço de coordenadas

### 30-layout.kdl

Configurações de layout de janelas:

- Espaçamentos (gaps)
- Anel de foco (focus-ring)
- Bordas (border)
- Sombras (shadow)
- Struts (espaçamentos externos)

### 40-spawn.kdl

Processos e configurações de inicialização:

- spawn-at-startup
- hotkey-overlay
- prefer-no-csd
- screenshot-path

### 50-animations.kdl

Configurações de animações (atualmente desabilitadas).

### 60-window-rules.kdl

Regras específicas para janelas:

- Firefox Picture-in-Picture (flutuante)
- Calculadora GNOME (flutuante)
- Diálogos de autenticação (flutuante)

### 70-binds.kdl

Todos os atalhos de teclado:

- Aplicações (Mod+T/N/E/M/D/P)
- Sistema (Mod+Shift+C, Mod+Escape)
- Screenshots e screencopy
- Controles de áudio e mídia
- Navegação entre janelas e workspaces
- Manipulação de janelas

## Uso

### Editar Configuração

1. **Edite os arquivos em `modules/`**, não o `config.kdl` diretamente
2. Execute o script de build:
   ```bash
   cd ~/.config/niri
   ./build/build-config.sh
   ```
3. Recarregue a configuração do Niri:
   - Atalho: `Mod+Shift+C`
   - Comando: `niri msg action load-config-file`

### Script de Build

O script `build/build-config.sh`:

- ✓ Faz backup automático do `config.kdl` existente
- ✓ Concatena todos os módulos em ordem numérica
- ✓ Adiciona cabeçalhos de aviso e separadores
- ✓ Valida a sintaxe com `niri validate` (se disponível)
- ✓ Fornece feedback colorido no terminal

### Script de Sessão

O script `session/niri-session.sh`:

- Carrega configurações do sistema (`/etc/profile`, `/etc/environment`)
- Carrega variáveis de ambiente Wayland via `wayland-common.sh`
- Configura locale (pt_BR.UTF-8)
- Exporta variáveis necessárias para Niri e aplicações Wayland
- Usado pelo greetd/tuigreet para iniciar a sessão

**Configuração no greetd:**

```toml
command = "tuigreet --remember --user-menu --asterisks --time --cmd /home/user/.config/niri/session/niri-session.sh"
```

### Variáveis de Configuração

O arquivo `variables/config.sh` centraliza variáveis reutilizáveis:

- Caminhos para scripts e logs
- IDs de dispositivos (touchpad, mouse)
- Configurações específicas do sistema
- Importado por scripts de sessão e utilitários

### Adicionar Novo Módulo

Para adicionar um novo módulo:

1. Crie arquivo em `modules/` com prefixo numérico apropriado
   ```bash
   touch modules/25-debug.kdl
   ```
2. Adicione seu conteúdo KDL
3. Execute `./build/build-config.sh`

A ordem de concatenação segue a ordenação alfabética dos nomes dos arquivos.

## Vantagens da Estrutura Modular

- **Organização**: Configurações agrupadas por função
- **Manutenção**: Fácil localizar e editar seções específicas
- **Versionamento**: Git diffs mais legíveis
- **Reutilização**: Módulos podem ser compartilhados entre máquinas
- **Segurança**: Backup automático antes de regenerar

## Observações

- **KDL não suporta includes nativos**: Por isso usamos concatenação via script
- **Sempre use o script**: Editar `config.kdl` diretamente será sobrescrito
- **Backups**: O script cria `.bak` automaticamente, mas mantenha seus próprios backups
- **Validação**: Execute `niri validate -c config.kdl` após mudanças

## Referências

- [Niri Configuration Wiki](https://yalter.github.io/niri/Configuration:-Introduction)
- [KDL Document Language](https://kdl.dev)
- [Niri GitHub Repository](https://github.com/YaLTeR/niri)
