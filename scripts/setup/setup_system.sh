#!/bin/bash
# scripts/setup_system.sh
# Copia arquivos de configuração do sistema para /etc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
SYSTEM_DIR="${DOTFILES_DIR}/system/etc"

if [ ! -d "$SYSTEM_DIR" ]; then
    error "Diretório $SYSTEM_DIR não encontrado!"
    exit 1
fi

log "Configurações de sistema encontradas em: $SYSTEM_DIR"
echo ""
echo "Arquivos que serão copiados para /etc:"
echo ""

# Listar arquivos que serão copiados
while IFS= read -r -d '' file; do
    rel_path="${file#"$SYSTEM_DIR"/}"
    echo "  - /etc/$rel_path"
done < <(find "$SYSTEM_DIR" -type f -print0)

echo ""
warn "ATENÇÃO: Esta operação modificará arquivos de sistema!"
warn "Certifique-se de ter backups ou entender o que será alterado."
echo ""

log "Deseja continuar? [y/N]"
read -r response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    warn "Operação cancelada pelo usuário"
    exit 0
fi

# Fazer backup dos arquivos existentes
BACKUP_DIR="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
log "Criando backup em: $BACKUP_DIR"

while IFS= read -r -d '' file; do
    rel_path="${file#"$SYSTEM_DIR"/}"
    dest="/etc/$rel_path"
    
    if [ -f "$dest" ]; then
        backup_path="$BACKUP_DIR/$rel_path"
        sudo mkdir -p "$(dirname "$backup_path")"
        sudo cp -a "$dest" "$backup_path"
    fi
done < <(find "$SYSTEM_DIR" -type f -print0)

success "Backup criado"

# Copiar arquivos
log "Copiando arquivos de configuração..."

copied=0
failed=0

find "$SYSTEM_DIR" -type f | while read -r file; do
    rel_path="${file#"$SYSTEM_DIR"/}"
    dest="/etc/$rel_path"
    dest_dir="$(dirname "$dest")"
    
    # Criar diretório de destino se não existir
    if [ ! -d "$dest_dir" ]; then
        sudo mkdir -p "$dest_dir"
    fi
    
    # Copiar arquivo
    if sudo cp "$file" "$dest"; then
        # Ajustar ownership para root:root
        sudo chown root:root "$dest"
        
        # Ajustar permissões baseado no tipo de arquivo
        case "$rel_path" in
            *tlp.conf|*iwd/*|*NetworkManager/*)
                sudo chmod 644 "$dest"
                ;;
            *security/*)
                sudo chmod 600 "$dest"
                ;;
            *)
                sudo chmod 644 "$dest"
                ;;
        esac
        
        success "Copiado: /etc/$rel_path (root:root)"
        ((copied++))
    else
        error "Falha ao copiar: /etc/$rel_path"
        ((failed++))
    fi
done

echo ""
echo "────────────────────────────────────────────"
success "Configurações de sistema aplicadas!"
echo "  Copiados: $copied"
echo "  Falhados: $failed"
echo "────────────────────────────────────────────"
echo ""
echo "Backup original: $BACKUP_DIR"
echo ""
warn "Alguns serviços podem precisar ser reiniciados para aplicar as mudanças"
