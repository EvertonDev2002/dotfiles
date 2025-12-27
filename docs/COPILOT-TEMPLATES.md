# Templates de Instruções do Copilot

> Documentação do sistema de templates para GitHub Copilot

Este sistema contém templates modulares para gerar instruções personalizadas do GitHub Copilot para diferentes tipos de projetos.

## Estrutura

Os templates estão localizados em `misc/copilot-templates/`:

```
misc/copilot-templates/
├── base.md              # Instruções base (princípios, código limpo, ferramentas comuns)
├── dotfiles.md          # Específico para dotfiles Linux/Wayland
├── python-core.md       # Python (core: style, typing, tests)
├── python-nlp-ml.md     # Python (NLP & ML guidelines)
├── fastapi.md           # FastAPI (routers, schemas, tests)
├── typescript-core.md   # TypeScript core (strict, zod)
├── react.md             # React + TypeScript (components, tests)
├── docker.md            # Docker (multi-stage, non-root)
├── kubernetes.md        # Kubernetes manifests & best practices
├── terraform.md         # Terraform modules & best practices
├── ansible.md           # Ansible roles & idempotency
├── java-core.md         # Java / Spring Boot (records, DI, tests)
├── linux-hardening.md   # Linux hardening (ssh, systemd, firewall)
├── web.md               # [legacy] Web summary (compat)
├── devops.md            # [legacy] DevOps summary (compat)
├── sysadmin.md          # [legacy] SysAdmin summary (compat)
└── scripts/generate.sh  # Script para combinar templates
```

## Como Usar

### 1. Gerar Instruções

Execute o script `generate.sh` com o tipo de projeto desejado:

```bash
# No diretório raiz do seu projeto
./scripts/tools/generate.sh [TIPO]
```

**Tipos disponíveis:**

- `dotfiles` - Configurações de sistema e dotfiles (pessoal)
- `python-core` - Python (style, typing, tests)
- `python-nlp-ml` - Python-focused NLP & ML guidelines
- `fastapi` - FastAPI APIs (routers, schemas, tests)
- `typescript-core` - TypeScript (strict, zod, tsconfig)
- `react` - React + TypeScript (components, tests)
- `docker` - Docker best practices (multi-stage, non-root)
- `kubernetes` - Kubernetes manifests & probes
- `terraform` - Terraform modules & remote state
- `ansible` - Ansible roles & idempotency
- `java-core` - Java / Spring Boot (records, DI, tests)
- `linux-hardening` - SSH, systemd, firewall best practices
- `web` - [legacy] Web summary (compat)
- `devops` - [legacy] DevOps summary (compat)
- `sysadmin` - [legacy] SysAdmin summary (compat)
- `base` - Apenas instruções base (sem contexto específico)

**Exemplos:**

```bash
# Para este repositório de dotfiles (padrão)
./misc/copilot-templates/generate.sh dotfiles

# Para um projeto Python (core)
cd ~/meu-projeto-python
~/dotfiles/misc/copilot-templates/generate.sh python-core

# Para um projeto Python NLP/ML
~/dotfiles/misc/copilot-templates/generate.sh python-nlp-ml

# Para backend FastAPI
~/dotfiles/misc/copilot-templates/generate.sh fastapi

# Para React + TypeScript
~/dotfiles/misc/copilot-templates/generate.sh react

# Para DevOps/IaC (Docker, K8s, Terraform, Ansible)
~/dotfiles/misc/copilot-templates/generate.sh docker kubernetes terraform ansible
```

### 2. Resultado

O script irá:

1. Criar o diretório `.github/` se não existir
2. Fazer backup do arquivo existente (se houver)
3. Gerar `.github/copilot-instructions.md` combinando:
   - Contexto específico do tipo de projeto
   - Instruções base (código limpo, ferramentas, boas práticas)

### 3. Uso Automático

O GitHub Copilot detecta e usa automaticamente o arquivo `.github/copilot-instructions.md` em todos os chats e sugestões de código naquele workspace.

## Conteúdo dos Templates

### base.md

Instruções base aplicáveis a qualquer projeto:

**Perfil do Desenvolvedor:**

- Engenheiro de software (Backend + DevOps)
- Áreas de estudo: SysAdmin, ML, LLMs, NLP
- 5+ anos de experiência em Linux
- Foco em automação

**Conteúdo organizado em 7 seções:**

1. **Fundamentos**: Comunicação, linguagem, padrões técnicos
2. **Estilo de Código**: Shell, Python, Java, TypeScript, configurações
3. **Qualidade de Código**: DRY, KISS, SRP, code smells, arquitetura
4. **DevOps & Infraestrutura**: Docker, Kubernetes, IaC, segurança, performance
5. **Ferramentas e Ambiente**: mise, uv, pnpm, VS Code, aliases Fish
6. **Workflows de Desenvolvimento**: Testes, debugging, commits, checklists
7. **Referências**: Links para documentações oficiais

### dotfiles.md

Específico para dotfiles Linux:

- Contexto: Arch Linux + Wayland
- Ferramentas: River, Sway, Hyprland, Waybar
- Scripts de setup e gerenciamento de pacotes
- Referências: Arch Wiki, documentação de compositors

### python.md

Específico para Python:

- Estrutura de projeto (biblioteca, CLI, Clean Architecture)
- NLP/ML: PyTorch, Transformers, spaCy, polars, MLflow
- Configuração pyproject.toml
- Testing com pytest
- CLI com Typer
- Logging estruturado
- Quantização de modelos (bitsandbytes, GGUF, ONNX)

### web.md

Específico para web (foco em backend):

**Backend (70% do conteúdo):**

- FastAPI: schemas, models, services, routes, testes
- Express/TypeScript: controllers, middleware, validation (Zod), error handling
- Prisma (Node.js) e SQLAlchemy (Python)
- Testes: pytest + httpx, Vitest + Supertest

**Frontend (30% do conteúdo):**

- React + TypeScript + Vite
- Componentes tipados, custom hooks
- Services/API layer
- State management (Zustand)

### java.md

Específico para Java/Spring Boot:

- Estruturas: Clean Architecture (Hexagonal) e MVC tradicional
- Spring Boot 3.x: Records, Constructor Injection, ProblemDetails
- Java 21: Virtual Threads, Pattern Matching
- JPA/Hibernate: entidades, repositórios, migrations
- Testing: JUnit 5, Mockito, Spring Test
- Maven/Gradle: configuração e dependências

### devops.md

Específico para DevOps & Infraestrutura:

- **Linting de IaC**: TFLint, ansible-lint, kube-linter, hadolint
- **Containers**: Docker multi-stage, Kubernetes manifests
- **IaC**: Terraform/OpenTofu, Ansible playbooks
- **CI/CD**: GitHub Actions, GitLab CI, ArgoCD
- **Observabilidade**: Prometheus, Grafana, Loki, structured logging
- **Security**: Secrets management, Network Policies

### sysadmin.md

Específico para SysAdmin & Linux Hardening:

- **Validação de sintaxe**: nginx, sshd, systemd, nftables, postfix
- **Init systems**: systemd (hardening, sandboxing) e runit (Artix)
- **Networking moderno**: iproute2, nftables, NetworkManager
- **Security**: SSH hardening, fail2ban, firewall
- **Backup & Monitoring**: estratégias de backup, journalctl, logs
- **Automação**: scripts idempotentes, validação antes de aplicar

## Personalização

### Criar Novo Template

1. Crie um novo arquivo `.md` em `misc/copilot-templates/`:

```bash
touch misc/copilot-templates/meu-tipo.md
```

2. Adicione o contexto específico (veja templates existentes como exemplo)

3. Gere as instruções:

```bash
./misc/copilot-templates/generate.sh meu-tipo
```

### Editar Templates Existentes

Edite os arquivos `.md` diretamente e regere as instruções:

```bash
# Editar
nano misc/copilot-templates/python.md

# Regenerar
./misc/copilot-templates/generate.sh python
```

## Workflow Recomendado

### Para Novos Projetos

```bash
# Criar projeto
mkdir meu-projeto
cd meu-projeto
git init

# Gerar instruções do Copilot
~/dotfiles/misc/copilot-templates/generate.sh python

# Verificar
cat .github/copilot-instructions.md

# Commitar
git add .github/copilot-instructions.md
git commit -m "feat: adiciona instruções do Copilot"
```

### Para Projetos Existentes

```bash
# No diretório do projeto
cd meu-projeto-existente

# Gerar instruções
~/dotfiles/misc/copilot-templates/generate.sh python

# Revisar backup (se havia arquivo anterior)
ls -la .github/copilot-instructions.md*

# Commitar
git add .github/copilot-instructions.md
git commit -m "feat: atualiza instruções do Copilot"
```

## Dicas

- **Backup automático**: O script cria backup com timestamp antes de sobrescrever
- **Versionamento**: Mantenha `.github/copilot-instructions.md` no Git
- **Equipes**: Compartilhe instruções com o time via repositório
- **Customização**: Edite o arquivo gerado para ajustes específicos do projeto
- **Atualização**: Regere periodicamente para incorporar melhorias nos templates

## Referências

- [VS Code Copilot Custom Instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [GitHub Copilot Best Practices](https://github.com/github/awesome-copilot)
- Templates localizados em: `misc/copilot-templates/`
