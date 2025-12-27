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

