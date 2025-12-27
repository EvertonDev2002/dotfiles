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

---

# Python Core — Instruções para o LLM

Contexto: projeto Python (biblioteca ou aplicação). Siga padrões de qualidade e gere código seguro e testável.

## Objetivo do assistant

- Fornecer código compatível com Python >=3.12, seguindo PEP8 e type hints.
- Criar ou sugerir testes com pytest para cada mudança funcional.
- Gerar `pyproject.toml` snippets e comandos de instalação/venv quando necessário.

## Restrições e estilo

- **Line length**: 79 caracteres (hard limit)
- **Indentação**: 4 espaços (nunca tabs)
- **Imports**: ordem stdlib → third-party → local, use `isort` ou `ruff`
- **Type hints**: obrigatórios em funções públicas, use `from __future__ import annotations` quando necessário
- **Docstrings**: Google style, primeira linha descritiva, Args/Returns/Raises quando aplicável
- **Pathlib**: use `Path` ao invés de `os.path`
- **F-strings**: prefira sobre `.format()` ou `%`
- **Exceptions**: específicas, nunca `except Exception:` sem re-raise

## Estrutura esperada

### Função típica

```python
from pathlib import Path
from typing import TypedDict

class Config(TypedDict):
    """Configuration dictionary structure."""
    host: str
    port: int
    debug: bool

def load_config(path: Path) -> Config:
    """Load configuration from TOML file.

    Args:
        path: Path to configuration file

    Returns:
        Parsed configuration dictionary

    Raises:
        FileNotFoundError: Config file doesn't exist
        ValueError: Invalid configuration format
    """
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {path}")

    import tomllib
    with path.open("rb") as f:
        data = tomllib.load(f)

    return Config(
        host=data["host"],
        port=data["port"],
        debug=data.get("debug", False)
    )
```

### Teste correspondente

```python
import pytest
from pathlib import Path

def test_load_config_success(tmp_path: Path):
    """Test successful config loading."""
    config_file = tmp_path / "config.toml"
    config_file.write_text('[app]\nhost = "localhost"\nport = 8000')

    config = load_config(config_file)

    assert config["host"] == "localhost"
    assert config["port"] == 8000
    assert config["debug"] is False

def test_load_config_missing_file():
    """Test config loading with missing file."""
    with pytest.raises(FileNotFoundError, match="Config not found"):
        load_config(Path("nonexistent.toml"))
```

## pyproject.toml snippet

```toml
[project]
name = "myproject"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=4.1",
    "ruff>=0.1",
]

[tool.ruff]
line-length = 79
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "PL", "PT"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src"
```

## Comandos de execução

```bash
# Setup
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"

# Run tests
pytest

# Format/lint
ruff format .
ruff check --fix .
```

## Saída esperada do LLM

Para cada request, forneça:

1. Código da função com type hints e docstring
2. Teste unitário (pytest) com fixture se necessário
3. Comando de execução (1 linha)

Exemplo: "Função `parse_url` implementada, teste em `test_parser.py`, execute com `pytest tests/test_parser.py -v`"

---

# Instruções Base — Foco LLM

Objetivo: instruções concisas que o LLM necessita para gerar código e mudanças seguras no repositório.

## Regras gerais

- Responda em **português brasileiro**; gere **código em inglês**.
- Formato da resposta:
  - 1. Código (marcado).
  - 2. Testes mínimos (quando aplicável).
  - 3. Explicação em até 2 linhas.
- Priorize: **tests**, **type hints**, **segurança** (validação/escaping), **reprodutibilidade** (seeds, envs).
- Não use emojis; use ícones (Nerd Font) apenas se solicitado explicitamente.

## Ambiente do desenvolvedor (VS Code)

**Formatação e estilo:**

- Line length: **79 caracteres** (Python, geral)
- Indentação: **2 espaços** (JS/TS/JSON/YAML), **4 espaços** (Python)
- Formatadores: Ruff (Python), Prettier (JS/TS/JSON/CSS)
- Linters: Ruff (Python), ESLint (JS/TS), Flake8 (Python)

**Ferramentas configuradas:**

- Python: `ruff format`, `ruff check`, `pytest`, `mypy`/`pyright` (type checking desabilitado por padrão)
- JavaScript/TypeScript: `prettier`, `eslint` (run on save)
- Shell: Bash IDE formatter
- Java: RedHat formatter

**Executores de código (code-runner):**

- Python: `clear ; python -u`
- JavaScript: `clear ; node`
- TypeScript: `ts-node`
- Java: `clear ; cd $dir && javac $fileName && java $fileNameWithoutExt`

**Boas práticas esperadas:**

- Format on save ativado (gere código já formatado)
- Organize imports automaticamente
- Use type hints (Python) e strict typing (TypeScript)
- Testes com `pytest` (Python) ou `vitest` (JS/TS)

## Exemplo de prompt ideal

"Implemente `function` X com typing, adicione `pytest` unit tests e explique em 1 linha como executar os testes."

## Do / Don't

- Do: oferecer snippets minimalistas testáveis e comandos para executar.
- Don't: fornecer longas explicações, guias de instalação passo-a-passo ou opiniões não solicitadas.

Use este arquivo em conjunto com templates específicos (`python-core.md`, `fastapi.md`, `docker.md`, etc.).

## Qualidade de Código

### Princípios Fundamentais

**SEMPRE aplique estes princípios ao criar ou modificar código:**

- **DRY (Don't Repeat Yourself)**: nunca duplique código

  - Extraia código repetido em funções reutilizáveis
  - Crie bibliotecas compartilhadas para lógica comum
  - Use herança, composição ou mixins quando apropriado

- **KISS (Keep It Simple, Stupid)**: prefira simplicidade sobre complexidade

  - Escolha a solução mais simples que funciona
  - Evite otimizações prematuras
  - Código simples é mais fácil de entender e manter

- **SRP (Single Responsibility Principle)**: cada unidade tem uma única responsabilidade
  - Uma função faz uma coisa e faz bem
  - Uma classe/módulo tem um único motivo para mudar
  - Separe lógica de negócio de lógica de apresentação

### Detecção de Code Smells

**Identifique e refatore estes problemas:**

- **Funções longas**: > 20-30 linhas indica necessidade de decomposição
- **Classes gigantes**: muitas responsabilidades, divida em classes menores
- **Código duplicado**: violação do DRY, extraia para função comum
- **Muitos parâmetros**: > 3-4 parâmetros, considere objeto de configuração
- **Comentários excessivos**: código deve ser autoexplicativo
- **Nomes vagos**: `data`, `temp`, `x` - use nomes descritivos
- **Condicionais aninhadas**: > 2 níveis, extraia em funções
- **Magic numbers**: use constantes nomeadas
- **God objects**: objetos que fazem tudo, refatore em objetos menores

### Princípios de Código Limpo

- **Nomenclatura**: use nomes descritivos e significativos

  - **Siga as convenções da comunidade de cada linguagem/framework**:
    - Python: `snake_case` para funções/variáveis, `PascalCase` para classes
    - JavaScript/TypeScript: `camelCase` para funções/variáveis, `PascalCase` para classes/componentes
    - Java: `camelCase` para métodos/variáveis, `PascalCase` para classes
    - Bash: `snake_case` ou `lowercase` para funções/variáveis
    - CSS/HTML: `kebab-case` para classes e IDs
    - Constantes: `UPPER_SNAKE_CASE` na maioria das linguagens
  - Funções: verbos (`calculate_total`, `send_email`, `handleClick`)
  - Classes: substantivos (`User`, `OrderProcessor`, `UserProfile`)
  - Booleanos: predicados (`is_valid`, `has_permission`, `canEdit`)
  - **Prefixo `handle` para event handlers**: `handleSubmit`, `handleClick`, `handleChange`
  - **Prefixo `on` para callbacks/props**: `onClick`, `onSubmit`, `onError` (comum em React/frameworks)
  - Use nomes do domínio do problema, não da implementação

- **Funções pequenas**: cada função deve fazer apenas uma coisa e fazê-la bem

  - Máximo 20-30 linhas
  - Um único nível de abstração
  - Sem efeitos colaterais escondidos

- **Comentários**: use para explicar "por quê", não "o quê"

  - Código deve ser autoexplicativo
  - Docstrings para APIs públicas
  - TODO/FIXME com contexto e data

- **Formatação consistente**: mantenha indentação e estilo uniformes

  - Use formatadores automáticos (black, prettier, etc.)
  - Siga guias de estilo da linguagem

- **Tratamento de erros**: sempre valide inputs e trate erros explicitamente
  - Fail fast: valide no início da função
  - Use exceções específicas, não genéricas
  - Nunca ignore erros silenciosamente

### Arquitetura de Software

#### Para Scripts Shell

- **Separação de responsabilidades**: divida scripts grandes em módulos menores
- **Biblioteca de funções comuns**: centralize funcionalidades reutilizáveis em `scripts/lib/`
- **Configuração separada**: mantenha configurações em arquivos separados (variáveis, constantes)
- **Single Responsibility**: cada script deve ter um propósito claro e único

#### Para Projetos Python

- **Clean Architecture**: organize código em camadas (domain, application, infrastructure)
- **Dependency Injection**: prefira passar dependências via parâmetros
- **SOLID Principles**: aplique quando apropriado ao contexto
  - Single Responsibility: uma classe/módulo, uma responsabilidade
  - Open/Closed: aberto para extensão, fechado para modificação
  - Liskov Substitution: subtipos devem ser substituíveis por seus tipos base
  - Interface Segregation: interfaces específicas são melhores que genéricas
  - Dependency Inversion: dependa de abstrações, não de implementações concretas
- **Estrutura de pastas**: organize por funcionalidade, não por tipo de arquivo

#### Boas Práticas Gerais

- **Modularidade**: código modular é mais fácil de testar e manter
- **Testabilidade**: escreva código que seja fácil de testar
- **Baixo acoplamento**: minimize dependências entre módulos
- **Alta coesão**: mantenha funcionalidades relacionadas juntas
- **Princípio KISS**: Keep It Simple, Stupid - prefira simplicidade

---

## DevOps & Infraestrutura

### Princípios Fundamentais

- **Idempotência**: Todo script ou comando de configuração deve ser seguro para rodar múltiplas vezes
- **Observabilidade**: Sempre inclua logs estruturados e health checks para serviços backend
- **Segurança (POLP)**: Princípio do Menor Privilégio - evite `sudo`/`root` a menos que necessário
- **Reprodutibilidade**: Use versionamento de dependências e lock files
- **Modern Linux Tooling**: Use ferramentas modernas (`eza`, `bat`, `fd`, `rg`) em contextos interativos, POSIX em scripts de automação para portabilidade

### Docker

- **Multi-stage builds**: SEMPRE use para reduzir tamanho de imagens
- **Imagens base leves**: Prefira `alpine`, `-slim` ou `distroless`
- **Non-root user**: NUNCA rode como root, use instrução `USER`
- **Health checks**: Defina `HEALTHCHECK` em produção
- **.dockerignore**: Sempre crie para excluir arquivos desnecessários

Exemplo:

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

RUN useradd -m appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1
```

### Kubernetes

- **Resource limits**: SEMPRE defina requests e limits
- **Probes**: Configure liveness e readiness probes
- **Namespaces**: Use para isolamento lógico
- **Labels**: Padronize labels para service discovery
- **Secrets**: Use ConfigMaps e Secrets, nunca hardcode configurações

### Infrastructure as Code

**Terraform/OpenTofu:**

- Mantenha estado remoto (Remote State)
- Use módulos para recursos repetitivos
- Siga convenção: `resource_type.name_of_resource`
- Sempre use variáveis para valores configuráveis

**Ansible:**

- Use roles para organização
- Sempre use tags para seletividade
- Handlers para restart de serviços
- Idempotência é essencial

### Systemd (Linux)

- **Unit Files**: Sempre defina `Restart=on-failure`
- **Sandboxing**: Use `ProtectSystem=full`, `PrivateTmp=true`, `NoNewPrivileges=true`
- **Validação**: Use `systemd-analyze security` para validar configurações
- **Logs**: Centralize com `journalctl`

### Networking (Linux)

- Use `iproute2` (`ip`) ao invés de `net-tools` (`ifconfig`)
- Prefira `nftables` sobre `iptables`
- Para DNS: use `systemd-resolved` ou `resolvectl`

### Segurança

**Desenvolvimento:**

- Validação de inputs (OWASP Top 10)
- Secrets em variáveis de ambiente (nunca em código)
- Dependências atualizadas (Dependabot, Renovate)
- Sanitize user input antes de processar
- Use prepared statements/parametrized queries

**Sistema:**

- Permissões mínimas: `chmod 600` para arquivos sensíveis
- Firewall configurado (ufw/nftables)
- SSH hardening: chaves, disable root, fail2ban
- Logs de auditoria habilitados

**Containers:**

- Scan de imagens (trivy, grype)
- Non-root user obrigatório
- Read-only filesystem quando possível
- Secrets via Docker secrets ou volumes criptografados

### Performance e Otimização

**Shell Scripts:**

- Evite subshells desnecessários: `$(cmd)` vs `` `cmd` ``
- Use built-ins ao invés de comandos externos quando possível
- Prefira `[[` ao invés de `[` em bash

**Python:**

- Use comprehensions ao invés de loops quando apropriado
- Considere `asyncio` para operações I/O intensivas
- Profile com `cProfile` antes de otimizar
- Use `polars` ou `numpy` para processamento pesado

**Java:**

- Virtual Threads (Java 21+) para I/O intensivo
- Lazy evaluation com Streams
- StringBuilder para concatenação de strings em loops
- Evite reflection em código crítico

**TypeScript/Node.js:**

- Entenda o Event Loop: não bloqueie com sync operations
- Use async/await patterns corretamente
- Bundling e tree-shaking para reduzir tamanho
- Worker threads para processamento CPU intensivo

**Docker:**

- Layer caching: ordene COPY de menos mutável para mais
- Multi-stage builds para imagens enxutas
- Use `.dockerignore` para excluir desnecessários
- BuildKit para builds paralelos e cache avançado

---

## Ferramentas e Ambiente

### Gerenciamento de Versões e Ambientes

- **Use `mise` para instalar e gerenciar linguagens de programação** (Python, Node.js, Go, Rust, etc.)
- **Use `mise` para configurar ambientes de desenvolvimento**
- Configure versões de runtime no `.mise.toml` ou `.tool-versions`
- Use `uv` para criar e gerenciar ambientes virtuais Python (após instalar Python com mise)
- Use `pnpm` para projetos Node.js (após instalar Node com mise)
- Evite usar gerenciadores de pacotes do sistema (pacman/yay) para instalar linguagens de programação

Exemplo de workflow:

```bash
# Instalar Python com mise
mise use python@3.12

# Criar ambiente virtual com uv
uv venv

# Instalar Node.js com mise
mise use node@20

# Usar pnpm para gerenciar pacotes
pnpm install
```

### Configuração de Ferramentas

**pyproject.toml (Python):**

- Configure ruff, black, pytest
- Use `uv init` para começar novos projetos

**mise.toml:**

- Pin versões específicas para reprodutibilidade
- Use plugins oficiais quando disponível

**.editorconfig:**

- Mantenha consistência entre editores
- Defina charset, indentação, fim de linha

### Ambiente de Desenvolvimento (VS Code)

**Ferramentas:**

- **ShellCheck Extension**: análise estática de shell scripts em tempo real
  - Detecta erros comuns e sugere boas práticas durante a escrita
  - Integrado ao editor para feedback instantâneo
  - Configurado para severity `warning` ou superior

**Shell e Aliases:**

O ambiente usa Fish shell interativo com aliases modernos. **SEMPRE considere estes aliases ao sugerir ou executar comandos:**

**Nota sobre uso:**

- **Em scripts**: use comandos nativos POSIX para portabilidade
- **Interativamente**: mencione versões com alias quando executar
- **Exemplos**: "Execute `ls -la`" (script) vs "Vejo pelo `ll` que..." (interativo)

**Utilitários Modernos:**

- `cp` → `rsync -ah --progress`
- `ls` → `eza --icons --classify --group-directories-first`
- `ll` → `eza -l --icons --group-directories-first --time-style=relative --git`
- `cat` → `bat --style=auto --paging=auto`
- `lt` → `eza --tree --level=2 --icons`
- `find` → `fd --hidden --follow --exclude .git`
- `grep` → `rg --smart-case --hidden --follow --glob '!.git'`
- `pn` → `pnpm`

**Gerenciamento de Pacotes:**

- `add-arch` → `yay -S --needed --noconfirm`
- `remove-arch` → `yay -Rns`
- `update-arch` → `flatpak update -y; and yay -Syu --noconfirm; and yay -Ycc`
- `flatpak-search` → `flatpak search --columns=name,application`

---

## Workflows de Desenvolvimento

### Testes e Validação

**Shell Scripts:**

- Validação com `shellcheck --severity=warning` (via extensão do VS Code para análise em tempo real)
- Teste com `bash -n script.sh` (dry-run)
- Use `bats` para testes automatizados quando apropriado
- A extensão ShellCheck do VS Code fornece feedback instantâneo sobre boas práticas durante a escrita

**Python:**

- Use `pytest` para testes
- Cobertura mínima: funções críticas devem ter testes
- Mock de comandos do sistema com `unittest.mock`

### Debugging e Troubleshooting

- Use `set -x` para debug de shell scripts
- Para Python: use `logging` ao invés de `print`
- Logs estruturados: inclua timestamp, nível, contexto
- Teste em ambiente isolado: containers ou VMs quando possível

### Commits e Versionamento

**Tipos de Conventional Commits:**

- `feat:` - nova funcionalidade para o usuário
- `fix:` - correção de bug
- `docs:` - apenas mudanças na documentação
- `style:` - formatação, ponto e vírgula, etc (sem mudança de código)
- `refactor:` - refatoração sem alterar funcionalidade
- `perf:` - melhorias de performance
- `test:` - adição ou correção de testes
- `chore:` - tarefas de manutenção (deps, config, build)
- `ci:` - mudanças em CI/CD
- `build:` - mudanças no sistema de build

**Boas Práticas:**

- Mensagens em português: `feat: adiciona suporte ao River`
- Commits atômicos: uma mudança lógica por commit
- Use `git commit --amend` para correções pequenas
- Primeira linha: máximo 72 caracteres
- Corpo opcional: explique "por quê", não "o quê"
- **Sugira commits frequentemente**: ao finalizar ciclos, sprints ou modificações significativas
  - Evite acumular múltiplas mudanças em um único commit
  - Facilita rollback e rastreamento de mudanças
  - Mantenha histórico limpo e semântico

### Checklist Antes de Finalizar

**Scripts (Shell):**

- [ ] Testado com shellcheck
- [ ] Executável (`chmod +x`)
- [ ] Testado em ambiente limpo
- [ ] Backup criado se modifica sistema
- [ ] Shebang correto (`#!/usr/bin/env bash`)
- [ ] `set -e` no início

**Python:**

- [ ] Type hints completos
- [ ] Docstrings presentes
- [ ] Formatado com ruff/black
- [ ] Imports organizados
- [ ] Sem warnings do mypy/pyright
- [ ] Testes passando

**TypeScript/React:**

- [ ] Types corretos (sem `any` desnecessário)
- [ ] Componentes testados
- [ ] Props documentadas (JSDoc)
- [ ] Formatado com prettier
- [ ] Sem warnings do ESLint
- [ ] Build produção funcional

**Java/Spring:**

- [ ] Records usados para DTOs
- [ ] Exceptions específicas
- [ ] Testes unitários presentes
- [ ] JavaDoc em APIs públicas
- [ ] Sem warnings do compilador
- [ ] Constructor injection usado

### Padrões de Resposta

### Pesquisa e Validação

- **SEMPRE** consulte documentações oficiais e recentes antes de sugerir mudanças
- **SEMPRE** verifique boas práticas validadas pela comunidade (GitHub, Arch Wiki, fóruns oficiais)
- Priorize soluções comprovadas e bem documentadas
- Verifique compatibilidade de versões e dependências
- Consulte issues e discussions de projetos para problemas conhecidos
- Use fontes confiáveis: documentação oficial > Arch Wiki > fóruns oficiais > Stack Overflow

### Ao Criar/Modificar Código

1. Pesquise boas práticas atuais para a tecnologia específica
2. Explique brevemente o que será feito
3. Implemente a solução seguindo padrões da comunidade
4. Destaque pontos importantes apenas se necessário
5. Seja direto e objetivo

### Ao Corrigir Erros

- Identifique a causa raiz
- Consulte documentação e issues relacionadas
- Explique o problema de forma clara
- Forneça a correção baseada em práticas validadas
- Sugira como evitar no futuro apenas se relevante

### Ao Sugerir Melhorias

- Pesquise soluções já existentes e bem estabelecidas
- Foque em melhorias práticas e aplicáveis
- Priorize legibilidade e manutenibilidade
- Considere o contexto do projeto (dotfiles pessoais)
- Verifique se a sugestão é amplamente recomendada pela comunidade

### Ao Finalizar Tarefas

- Sugira commit com mensagem apropriada
- Use tipo correto de Conventional Commit
- Mantenha mensagem descritiva mas concisa
- Separe mudanças lógicas em commits diferentes
- Inclua contexto relevante no corpo do commit quando necessário

---

## Linters e Formatadores

### Shell/Bash

- **Análise estática**: ShellCheck (via extensão VS Code)
- **Formatação**: shfmt
- **Stack mínimo**: ShellCheck + shfmt

### Python

- **Linter + Formatter**: Ruff (all-in-one, baseado em Rust)
- **Type checking**: mypy ou pyright
- **Stack atual**: UV + Ruff (já ideal)

### Java

- **IDE**: IntelliJ IDEA (linter integrado)
- **Formatter**: Spotless (apenas para projetos em equipe)
- **Evite**: Checkstyle/PMD para projetos pessoais

### TypeScript/Node.js

- **Linter**: ESLint + @typescript-eslint
- **Formatter**: Prettier
- **Stack atual**: já configurado (nada a adicionar)

### PHP (futuro)

- **Verificação**: PHP_CodeSniffer
- **Correção**: PHP-CS-Fixer

### Princípios para Escolha de Linters

**Adicione ferramentas apenas se**:

- 󰄬 Resolver problema real no workflow
- 󰄬 Não sobrepor funcionalidade existente
- 󰄬 Ter comunidade ativa e manutenção regular
- 󰄬 Integrar bem com stack atual

**Evite**:

- 󰅙 Redundância (Bashate vs ShellCheck)
- 󰅙 Forks inativos (shellcheck-ng)
- 󰅙 Overkill para projetos pessoais (Checkstyle/PMD em Java)
- 󰅙 Ferramentas opinativas demais para contexto genérico

---

## Referências Úteis

### Shell & Scripting

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)

### Ferramentas de Desenvolvimento

- [UV Documentation](https://docs.astral.sh/uv/)
- [PNPM Documentation](https://pnpm.io/)
- [Mise Documentation](https://mise.jdx.dev/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)

### Backend & Frameworks

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Documentation](https://react.dev/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### DevOps & Infrastructure

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Segurança

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### Design & Tipografia

- [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet)

