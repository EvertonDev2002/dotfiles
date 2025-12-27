# 󰊢 GitHub Actions - Validação de Dotfiles

Este repositório usa GitHub Actions para validação automática de código e commits.

## Validações Automáticas

### ShellCheck (Análise Estática de Scripts)

- Valida todos os scripts em `scripts/`
- Detecta erros comuns de sintaxe e boas práticas
- Severidade mínima: `warning`
- **Ferramenta**: [shellcheck](https://github.com/koalaman/shellcheck)

### Estrutura do Repositório

**Diretórios obrigatórios:**

- `config/`
- `scripts/setup/`
- `scripts/lib/`
- `pkgs/yay/`
- `pkgs/flatpak/`
- `system/etc/`
- `docs/`

**Arquivos obrigatórios:**

- `README.md`
- `install.sh`
- `pkgs/yay/pkglist.txt`
- `pkgs/flatpak/flatpaklist.txt`

### Validação de Scripts

**Verifica:**

- Permissões de execução (`chmod +x`)
- Sintaxe Bash (`bash -n`)
- Shebang correto (`#!/usr/bin/env bash` ou `#!/bin/sh`)

**Scripts validados:**

- `install.sh`
- `scripts/setup/*.sh`
- `config/scripts/.local/bin/init/*.sh`
- `config/scripts/.local/bin/utils/*.sh`

### Validação de Arquivos de Configuração

**Tipos validados:**

- JSON/JSONC (sintaxe)
- YAML (futuro)

### Conventional Commits (Pull Requests)

**Formato obrigatório:**

```
tipo(escopo?): descrição

Tipos válidos:
- feat:     nova funcionalidade
- fix:      correção de bug
- docs:     apenas documentação
- style:    formatação (sem mudança de código)
- refactor: refatoração sem alterar funcionalidade
- perf:     melhorias de performance
- test:     adição ou correção de testes
- chore:    tarefas de manutenção
- ci:       mudanças em CI/CD
- build:    mudanças no sistema de build
- revert:   reverter commit anterior
```

**Exemplos válidos:**

```
feat: adiciona suporte ao Hyprland
fix: corrige erro de sintaxe no riverctl
docs: atualiza README com novos atalhos
chore(deps): atualiza lista de pacotes
refactor: reorganiza scripts de init
```

**Exemplos inválidos:**

```
Add new feature          ❌ (sem tipo)
feat adiciona suporte    ❌ (sem dois pontos)
feature: nova função     ❌ (tipo inválido)
feat: muito longo blablablablablabla... ❌ (> 100 caracteres)
```

## 󰑮 Executar Localmente

### ShellCheck

```bash
# Instalar ShellCheck
yay -S shellcheck

# Validar script específico
shellcheck scripts/setup/setup_repos.sh

# Validar todos os scripts
find scripts -type f -name "*.sh" -exec shellcheck {} \;
```

### Validação de Sintaxe Bash

```bash
# Script específico
bash -n scripts/setup/setup_repos.sh

# Todos os scripts
find scripts config/scripts -type f -name "*.sh" -exec bash -n {} \;
```

### Validação de JSON

```bash
# Validar arquivo JSON
jq empty config/waybar/.config/waybar/config.jsonc

# Validar todos os JSON
find config -name "*.json" -exec jq empty {} \;
```

## 󰚩 Workflow

**Trigger:**

- Push para `main`, `master` ou `develop`
- Pull Requests para essas branches

**Jobs executados:**

1. `shellcheck` - Análise estática de scripts
2. `validate-structure` - Estrutura de diretórios/arquivos
3. `validate-scripts` - Permissões e sintaxe
4. `validate-configs` - Arquivos de configuração
5. `conventional-commits` - Mensagens de commit (apenas PRs)
6. `summary` - Resumo das validações

**Status:**

- ✓ Verde: Todas as validações passaram
- ❌ Vermelho: Alguma validação falhou

## 󰌢 Boas Práticas

1. **Antes de commitar:**

   ```bash
   # Validar scripts localmente
   shellcheck scripts/setup/*.sh

   # Verificar sintaxe
   bash -n scripts/setup/*.sh

   # Verificar permissões
   ls -l install.sh scripts/setup/*.sh
   ```

2. **Mensagens de commit:**

   - Sempre use Conventional Commits
   - Descrição clara e concisa (< 100 caracteres)
   - Corpo opcional para contexto adicional

3. **Pull Requests:**
   - Aguarde validações passarem antes de merge
   - Corrija problemas apontados pelo CI
   - Revise logs de falhas no GitHub Actions

## 󰋗 Troubleshooting

**ShellCheck falha:**

- Verifique warnings/errors no log do GitHub Actions
- Consulte [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- Corrija localmente e force push

**Conventional Commits falha:**

- Reescreva mensagens de commit: `git commit --amend`
- Para múltiplos commits: `git rebase -i origin/main`
- Force push após correção: `git push --force-with-lease`

**Estrutura inválida:**

- Verifique se todos os diretórios/arquivos obrigatórios existem
- Compare com a estrutura esperada na documentação

## 󰌨 Desabilitar Validações

**Temporariamente (commit específico):**

```bash
# Pular CI (use com cautela!)
git commit -m "feat: emergency fix [skip ci]"
```

**Permanentemente:**

- Edite `.github/workflows/validate.yml`
- Comente ou remova jobs específicos
- Commit e push as mudanças

---

**󰋗 Nota:** As validações garantem qualidade e consistência do código. Sempre corrija problemas ao invés de desabilitar checks.
