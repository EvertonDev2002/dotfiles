#!/bin/bash
# scripts/setup/setup_system.sh
# Copia arquivos de configuração do sistema para /etc

# shellcheck source=./lib/bootstrap.sh
PATH_BOOTSTRAP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/bootstrap.sh"

# shellcheck source=../lib/bootstrap.sh
# shellcheck disable=SC1091
if ! source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/lib/bootstrap.sh" 2>/dev/null; then
    # shellcheck disable=SC1091
    source "$PATH_BOOTSTRAP"
fi

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

# Listar todos os arquivos em um array
mapfile -d '' files < <(find "$SYSTEM_DIR" -type f -print0)

# Fazer backup dos arquivos existentes
for file in "${files[@]}"; do
    rel_path="${file#"$SYSTEM_DIR"/}"
    dest="/etc/$rel_path"
    if [ -f "$dest" ]; then
        backup_path="$BACKUP_DIR/$rel_path"
        sudo mkdir -p "$(dirname "$backup_path")"
        sudo cp -a "$dest" "$backup_path"
    fi
done

success "Backup criado"

# Copiar arquivos
log "Copiando arquivos de configuração..."
echo ""

copied=0
failed=0
skipped=0

for file in "${files[@]}"; do
    # Pular arquivos vazios ou .keep
    if [[ "$(basename "$file")" == ".keep" ]]; then
        log "Ignorando: $(basename "$file")"
        skipped=$((skipped + 1))
        continue
    fi

    rel_path="${file#"$SYSTEM_DIR"/}"
    dest="/etc/$rel_path"
    dest_dir="$(dirname "$dest")"

    # Criar diretório de destino se não existir
    if [ ! -d "$dest_dir" ]; then
        if ! sudo mkdir -p "$dest_dir"; then
            error "  Falha ao criar diretório: $dest_dir"
            ((failed++))
            continue
        fi
    fi

    # Copiar arquivo
    if sudo cp -v "$file" "$dest"; then
        if sudo chown root:root "$dest"; then
            case "$rel_path" in
                *tlp.conf | *iwd/* | *NetworkManager/*)
                    sudo chmod 644 "$dest" || { echo "chmod falhou mas continuando..."; }
                    ;;
                *security/*)
                    sudo chmod 600 "$dest" || { echo "chmod falhou mas continuando..."; }
                    ;;
                *runit/sv/*/log/run | *runit/sv/*/run | *runit/sv/*/finish)
                    sudo chmod 755 "$dest" || { echo "chmod falhou mas continuando..."; }
                    ;;
                *)
                    sudo chmod 644 "$dest" || { echo "chmod falhou mas continuando..."; }
                    ;;
            esac
            success "  ✓ Copiado: /etc/$rel_path"
            copied=$((copied + 1))
        else
            error "  ✗ Falha ao alterar proprietário: /etc/$rel_path"
            failed=$((failed + 1))
        fi
    else
        error "  ✗ Falha ao copiar: /etc/$rel_path"
        failed=$((failed + 1))
    fi

done

echo ""
echo "────────────────────────────────────────────"
success "Configurações de sistema aplicadas!"
echo "  Total encontrado: ${#files[@]}"
echo "  Copiados: $copied"
echo "  Falhados: $failed"
echo "  Ignorados: $skipped"
echo "────────────────────────────────────────────"
echo ""
echo "Backup original: $BACKUP_DIR"
echo ""
warn "Alguns serviços podem precisar ser reiniciados para aplicar as mudanças"
