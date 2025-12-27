#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly TEMPLATES_DIR="$SCRIPT_DIR/../../misc/copilot-templates"
readonly BASE_FILE="$TEMPLATES_DIR/base.md"
readonly OUTPUT_FOLDER="$TEMPLATES_DIR/instructions"
readonly OUTPUT_DIR="$OUTPUT_FOLDER/.github"
readonly OUTPUT_FILE="$OUTPUT_DIR/copilot-instructions.md"

# Colors
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

function show_usage() {
    cat << EOF
Uso: $(basename "$0") [TIPO1] [TIPO2] ...

Gera pasta 'instructions' com instruções do Copilot prontas para usar.
Você pode combinar múltiplos templates (ex: python-core docker).

TIPOS disponíveis:
  dotfiles           - Configurações de sistema e dotfiles
  python-core        - Projeto Python (core: style, typing, tests)
  python-nlp-ml      - Python (NLP/ML guidelines)
  fastapi            - FastAPI (routers, schemas, tests)
  typescript-core    - TypeScript (strict, zod, tsconfig)
  react              - React + TypeScript (components, tests)
  docker             - Docker (multi-stage, non-root)
  kubernetes         - Kubernetes (manifests, probes, resources)
  terraform          - Terraform modules & best practices
  ansible            - Ansible (playbooks, roles, idempotency)
  java-core          - Java / Spring Boot (records, DI, tests)
  linux-hardening    - Linux hardening (SSH, systemd, firewall)
  web                - [legacy] Web summary
  devops             - [legacy] DevOps summary
  sysadmin           - [legacy] SysAdmin summary
  base               - Apenas instruções base

Sem argumentos: abre menu interativo

Exemplos:
  $(basename "$0") python-core docker
  $(basename "$0") fastapi typescript-core base

Estrutura gerada:
  misc/copilot-templates/instructions/
  └── .github/
      └── copilot-instructions.md

Para usar em outro projeto:
  cp -r misc/copilot-templates/instructions/.github /caminho/do/projeto/
EOF
}

function show_menu() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Gerador de Instruções do GitHub Copilot        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Selecione os templates (separe por espaço, ex: 1 5 para Python+Docker):"
    echo ""
    echo -e "  1) Dotfiles"
    echo -e "  2) Python Core (style, typing, tests)"
    echo -e "  3) Python NLP/ML"
    echo -e "  4) FastAPI"
    echo -e "  5) TypeScript Core"
    echo -e "  6) React (TypeScript)"
    echo -e "  7) Docker"
    echo -e "  8) Kubernetes"
    echo -e "  9) Terraform"
    echo -e " 10) Ansible"
    echo -e " 11) Java Core"
    echo -e " 12) Linux Hardening"
    echo -e " 13) Web (legacy)"
    echo -e " 14) DevOps (legacy)"
    echo -e " 15) SysAdmin (legacy)"
    echo -e " 16) Base (somente)"
    echo ""
    echo -e "  0) Sair"
    echo ""
}

function generate_instructions() {
    local -a types=("$@")
    
    if [[ ${#types[@]} -eq 0 ]]; then
        echo -e "${YELLOW}󰅙${NC} Erro: Nenhum template especificado!"
        exit 1
    fi
    
    # Validar que todos os templates existem
    for type in "${types[@]}"; do
        local template_file="$TEMPLATES_DIR/${type}.md"
        if [[ ! -f "$template_file" ]] && [[ "$type" != "base" ]]; then
            echo -e "${YELLOW}󰀦${NC} Template '${type}' não encontrado."
            echo ""
            echo "Templates disponíveis:"
            for file in "$TEMPLATES_DIR"/*.md; do
                if [[ "$(basename "$file")" != "base.md" ]]; then
                    echo "  - $(basename "$file" .md)"
                fi
            done
            exit 1
        fi
    done
    
    # Criar estrutura de pastas
    echo -e "${BLUE}󰋗${NC} Criando estrutura de pastas..."
    mkdir -p "$OUTPUT_DIR"
    
    # Backup se já existir
    if [[ -f "$OUTPUT_FILE" ]]; then
        local backup
        backup="${OUTPUT_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$OUTPUT_FILE" "$backup"
        echo -e "${YELLOW}󰋗${NC} Backup: $backup"
    fi
    
    # Gerar arquivo combinado
    echo -e "${BLUE}󰋗${NC} Gerando instruções..."
    
    local first=true
    local template_names=""
    
    # Adicionar cada template (exceto base)
    for type in "${types[@]}"; do
        if [[ "$type" == "base" ]]; then
            continue
        fi
        
        local template_file="$TEMPLATES_DIR/${type}.md"
        
        if [[ "$first" == true ]]; then
            cat "$template_file" > "$OUTPUT_FILE"
            template_names="$type"
            first=false
        else
            { echo ""; echo "---"; echo ""; cat "$template_file"; } >> "$OUTPUT_FILE"
            template_names="${template_names} + ${type}"
        fi
    done
    
    # Adicionar base no final (a menos que só base foi solicitado)
    if [[ ${#types[@]} -eq 1 ]] && [[ "${types[0]}" == "base" ]]; then
        cat "$BASE_FILE" > "$OUTPUT_FILE"
        template_names="base"
    else
        { echo ""; echo "---"; echo ""; cat "$BASE_FILE"; } >> "$OUTPUT_FILE"
        template_names="${template_names} + base"
    fi
    
    # Contar linhas
    local line_count
    line_count=$(wc -l < "$OUTPUT_FILE")
    
    # Mensagens finais
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Geração Concluída!                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}󰄬${NC} Arquivo gerado: ${YELLOW}$OUTPUT_FILE${NC}"
    echo -e "${GREEN}󰄬${NC} Total de linhas: ${YELLOW}$line_count${NC}"
    echo -e "${GREEN}󰄬${NC} Templates: ${YELLOW}${template_names}${NC}"
    echo ""
    echo -e "${BLUE}󰋗 Estrutura gerada:${NC}"
    echo ""
    tree -L 3 "$OUTPUT_FOLDER" 2>/dev/null || ls -R "$OUTPUT_FOLDER"
    echo ""
    echo -e "${BLUE}󰋗 Para usar em outro projeto:${NC}"
    echo ""
    echo -e "  ${GREEN}cd /caminho/do/seu/projeto${NC}"
    echo -e "  ${GREEN}cp -r $OUTPUT_FOLDER/.github ./${NC}"
    echo ""
    echo -e "${BLUE}󰋗 O GitHub Copilot usará automaticamente estas instruções!${NC}"
    echo ""
}

function main() {
    local -a types=()
    
    # Ajuda
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Menu interativo se não houver argumentos
    if [[ $# -eq 0 ]]; then
        show_menu
        read -rp "Digite sua escolha: " choices
        
        if [[ "$choices" == "0" ]]; then
            echo ""
            echo "Operação cancelada."
            exit 0
        fi
        
        # Parse choices
        local type_map=("dotfiles" "python-core" "python-nlp-ml" "fastapi" "typescript-core" "react" "docker" "kubernetes" "terraform" "ansible" "java-core" "linux-hardening" "web" "devops" "sysadmin" "base")
        
        for choice in $choices; do
            case $choice in
                1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16)
                    types+=("${type_map[$((choice-1))]}")
                    ;;
                0)
                    echo ""
                    echo "Operação cancelada."
                    exit 0
                    ;;
                *)
                    echo -e "${YELLOW}󰅙${NC} Opção inválida: $choice"
                    exit 1
                    ;;
            esac
        done

        if [[ ${#types[@]} -eq 0 ]]; then
            echo -e "${YELLOW}󰅙${NC} Nenhum template selecionado!"
            exit 1
        fi
    else
        # Argumentos da linha de comando
        types=("$@")
        
        # Validar tipos
        local valid_types=("dotfiles" "python-core" "python-nlp-ml" "fastapi" "typescript-core" "react" "docker" "kubernetes" "terraform" "ansible" "java-core" "linux-hardening" "web" "devops" "sysadmin" "base")
        for type in "${types[@]}"; do
            local valid=false
            for valid_type in "${valid_types[@]}"; do
                if [[ "$type" == "$valid_type" ]]; then
                    valid=true
                    break
                fi
            done
            
            if [[ "$valid" == false ]]; then
                echo -e "${YELLOW}󰅙${NC} Tipo inválido: $type"
                echo ""
                show_usage
                exit 1
            fi
        done
    fi
    
    generate_instructions "${types[@]}"
}

main "$@"
