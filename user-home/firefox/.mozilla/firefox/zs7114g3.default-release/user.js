/* CUSTOMIZAÇÃO DE UI & TEMAS */
// Habilita o carregamento de userChrome.css e userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Força tema não nativo (útil para consistência visual no Linux)
user_pref("widget.non-native-theme.enabled", true);
// Habilita abas verticais e nova barra lateral
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.revamp", true);
user_pref("sidebar.visibility", "hide-sidebar"); // Começa oculto ou conforme estado
// Remove o título da janela quando as abas estão na barra de título
user_pref("browser.tabs.inTitlebar", 1);

/* PERFORMANCE & HARDWARE (VA-API/Intel) */
// Força aceleração WebRender
user_pref("gfx.webrender.all", true);
// Força aceleração de camadas
user_pref("layers.acceleration.force-enabled", true);
// Habilita decodificação de vídeo por hardware (VA-API)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
// Desabilita FFVPX para forçar o uso de decodificadores do sistema
user_pref("media.ffvpx.enabled", false);
// Desativa o cache em disco (HD/SSD)
user_pref("browser.cache.disk.enable", false);
// Força o uso de cache na RAM
user_pref("browser.cache.memory.enable", true);
// Gerenciar dinamicamente o uso de cache na RAM
user_pref("browser.cache.memory.capacity", -1);
// Desativa o "Session Restore" excessivo
user_pref("browser.sessionstore.interval", 300000);

/* PRIVACIDADE & SEGURANÇA */
// Desabilita Telemetria e Estudos (Normandy/Shield)
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("app.normandy.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
// Proteção contra Fingerprinting (RFP)
user_pref("privacy.fingerprintingProtection", true);
// Habilita Global Privacy Control
user_pref("privacy.globalprivacycontrol.enabled", true); // Corrigido de 'was_ever_enabled' para a pref ativa
// Força modo HTTPS-Only
user_pref("dom.security.https_only_mode", true);
// Desabilita pre-fetching de DNS e páginas (reduz vazamento de dados)
user_pref("network.prefetch-next", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.search.suggest.enabled", false); // Desabilita sugestões de pesquisa (envia o que digita para o motor)

/* LIMPEZA E COMPORTAMENTO */
// Não salvar senhas no navegador
user_pref("signon.rememberSignons", false);
// Não preencher formulários automaticamente
user_pref("browser.formfill.enable", false);
// Limpar dados ao fechar (conforme seu prefs.js)
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cookies", false); // Você definiu false, mantendo login
user_pref("privacy.clearOnShutdown.sessions", false); // Mantém sessões abertas
user_pref("privacy.clearOnShutdown_v2.formdata", true); // Limpa dados de formulário
user_pref("privacy.clearSiteData.browsingHistoryAndDownloads", true);

/* BARRA DE ENDEREÇOS (URLBAR) LIMPA */
// Remove sugestões desnecessárias na barra de endereços
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.shortcuts.bookmarks", false);
user_pref("browser.urlbar.shortcuts.history", false);
user_pref("browser.urlbar.shortcuts.tabs", false);
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);

/* OUTROS */
// Desabilita reprodução automática de mídia
user_pref("media.autoplay.default", 5);
user_pref("media.autoplay.blocking_policy", 2);
// Impede que o navegador verifique se é o padrão na inicialização
user_pref("browser.shell.checkDefaultBrowser", false);
// Define localização padrão dos favoritos
user_pref("browser.bookmarks.defaultLocation", "toolbar_____");
// Idioma
user_pref("intl.accept_languages", "pt-br,en-us,en");
// Impede que sites mexam no tamanho da sua janela ou movam ela
user_pref("dom.disable_window_move_resize", true);
