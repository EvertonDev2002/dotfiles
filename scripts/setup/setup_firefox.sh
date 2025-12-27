#!/bin/bash
# scripts/setup_firefox.sh
# Cria links simbólicos do user.js e chrome/ para o perfil Firefox ativo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

log "Configurando Firefox..."

# Localizar perfil Firefox
FIREFOX_DIR="$HOME/.mozilla/firefox"
PROFILES_INI="$FIREFOX_DIR/profiles.ini"

if [ ! -f "$PROFILES_INI" ]; then
    error "Firefox não encontrado. Execute o Firefox pelo menos uma vez para criar o perfil."
    exit 1
fi

# Encontrar perfil padrão
PROFILE_PATH=$(grep -E "^Path=" "$PROFILES_INI" | grep "default-release" | head -n1 | cut -d'=' -f2)

if [ -z "$PROFILE_PATH" ]; then
    PROFILE_PATH=$(grep -E "^Path=" "$PROFILES_INI" | head -n1 | cut -d'=' -f2)
fi

if [ -z "$PROFILE_PATH" ]; then
    error "Nenhum perfil Firefox encontrado em $PROFILES_INI"
    exit 1
fi

PROFILE_FULL_PATH="$FIREFOX_DIR/$PROFILE_PATH"

if [ ! -d "$PROFILE_FULL_PATH" ]; then
    error "Diretório do perfil não existe: $PROFILE_FULL_PATH"
    exit 1
fi

success "Perfil encontrado: $PROFILE_PATH"

# Arquivos fonte
USER_JS_SOURCE="$DOTFILES_DIR/misc/browser/firefox/.mozilla/firefox/user.js"
CHROME_SOURCE="$DOTFILES_DIR/misc/browser/firefox/.mozilla/firefox/chrome"

# Destinos
USER_JS_TARGET="$PROFILE_FULL_PATH/user.js"
CHROME_TARGET="$PROFILE_FULL_PATH/chrome"

# Criar link para user.js
if [ -f "$USER_JS_SOURCE" ]; then
    if [ -L "$USER_JS_TARGET" ]; then
        warn "Link simbólico user.js já existe, removendo..."
        rm "$USER_JS_TARGET"
    elif [ -f "$USER_JS_TARGET" ]; then
        log "Fazendo backup do user.js existente..."
        mv "$USER_JS_TARGET" "$USER_JS_TARGET.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    log "Criando link simbólico: user.js -> $USER_JS_SOURCE"
    ln -s "$USER_JS_SOURCE" "$USER_JS_TARGET"
    success "user.js linkado"
else
    warn "user.js não encontrado em $USER_JS_SOURCE"
fi

# Criar link para chrome/
if [ -d "$CHROME_SOURCE" ]; then
    if [ -L "$CHROME_TARGET" ]; then
        warn "Link simbólico chrome/ já existe, removendo..."
        rm "$CHROME_TARGET"
    elif [ -d "$CHROME_TARGET" ]; then
        log "Fazendo backup do chrome/ existente..."
        mv "$CHROME_TARGET" "$CHROME_TARGET.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    log "Criando link simbólico: chrome/ -> $CHROME_SOURCE"
    ln -s "$CHROME_SOURCE" "$CHROME_TARGET"
    success "chrome/ linkado"
else
    warn "chrome/ não encontrado em $CHROME_SOURCE"
fi

echo ""
success "Configuração do Firefox concluída!"
echo ""
echo "Perfil: $PROFILE_FULL_PATH"
echo "  - user.js: $(readlink -f "$USER_JS_TARGET" 2>/dev/null || echo 'não linkado')"
echo "  - chrome/: $(readlink -f "$CHROME_TARGET" 2>/dev/null || echo 'não linkado')"
echo ""
warn "Reinicie o Firefox para aplicar as configurações"
