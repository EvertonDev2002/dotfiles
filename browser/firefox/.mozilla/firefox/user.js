// === CUSTOMIZAÇÃO DE UI & TEMAS ===

// Permite carregar estilos de perfil (userChrome.css / userContent.css)
user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);
// Força uso de tema não nativo (consistência visual no Linux)
user_pref('widget.non-native-theme.enabled', true);
// Habilita abas verticais e nova barra lateral
// Habilita abas verticais na barra lateral
user_pref('sidebar.verticalTabs', true);
// Ativa a versão revamp da sidebar
user_pref('sidebar.revamp', true);
// Define a visibilidade da sidebar (ex: 'hide-sidebar')
user_pref('sidebar.visibility', 'hide-sidebar');
// Posiciona sidebar no final (false = direita, true = esquerda)
user_pref('sidebar.position_start', false);

// Remove o título da janela quando as abas estão na barra de título
// user_pref("browser.tabs.inTitlebar", 1);

// === PERFORMANCE & HARDWARE ===
// (VA-API/Intel)
// Habilita WebRender (renderização via GPU)
user_pref('gfx.webrender.all', true);
// Controla aceleração de camadas (true = forçar)
user_pref('layers.acceleration.force-enabled', false);
// Habilita VA-API para decodificação por hardware
user_pref('media.ffmpeg.vaapi.enabled', true);
// Força uso de decodificação de vídeo por hardware quando possível
user_pref('media.hardware-video-decoding.force-enabled', false);
// Desativa o decodificador FFvpx para usar decodificadores do sistema
user_pref('media.ffvpx.enabled', false);
// Ativa cache em memória (RAM)
user_pref('browser.cache.memory.enable', true);
// Habilita o cache de bytecode JS (melhora a inicialização de páginas pesadas)
user_pref('dom.script_loader.bytecode_cache.enabled', true);
// -1 = Heurística agressiva
user_pref('dom.script_loader.bytecode_cache.strategy', -1);

// === PRIVACIDADE & SEGURANÇA ===

// Desativa prompt de relatório de telemetria na primeira execução
user_pref('toolkit.telemetry.reportingpolicy.firstRun', false);
// Ativa proteção contra fingerprinting
user_pref('privacy.fingerprintingProtection', true);
// Força conexões via HTTPS sempre que possível
user_pref('dom.security.https_only_mode', true);
// Define DuckDuckGo como mecanismo de busca padrão via política
user_pref(
  'browser.policies.runOncePerModification.setDefaultSearchEngine',
  'DuckDuckGo'
);

// === LIMPEZA E COMPORTAMENTO ===
// Não armazenar senhas salvas
user_pref('signon.rememberSignons', false);
// Não mostrar topsites na newtab
user_pref('browser.newtabpage.activity-stream.feeds.topsites', false);
// Não esconder botão de downloads automaticamente
user_pref('browser.download.autohideButton', false);
// Ativa ordenação por mais recentemente usado no Ctrl+Tab
user_pref('browser.ctrlTab.sortByRecentlyUsed', true);
// Desativa a visualização de abas com Ctrl+Tab
user_pref('browser.ctrlTab.sortByRecentlyUsed', false);
// Controla uso de cores do documento
user_pref('browser.display.document_color_use', 0);
// Sanitizar dados ao encerrar
user_pref('privacy.sanitize.sanitizeOnShutdown', true);
// Não limpar cookies ao encerrar
user_pref('privacy.clearOnShutdown.cookies', false);
// Não limpar sessões ao encerrar
user_pref('privacy.clearOnShutdown.sessions', false);
// Limpar formdata ao encerrar (v2)
user_pref('privacy.clearOnShutdown_v2.formdata', true);
// Limpar histórico e downloads ao encerrar
user_pref('privacy.clearSiteData.browsingHistoryAndDownloads', true);
// Não fecha janela ao fechar a última aba
user_pref('browser.tabs.closeWindowWithLastTab', false);
// Página de inicialização (1 = página inicial)
user_pref('browser.startup.page', 1);
// Configuração dos botões na barra de abas horizontal
user_pref(
  'browser.uiCustomization.horizontalTabstrip',
  '["firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"]'
);
user_pref(
  // Estado personalizado da UI (posicionamento de botões e áreas)
  'browser.uiCustomization.state',
  '{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["ublock0_raymondhill_net-browser-action","languagetool-webextension_languagetool_org-browser-action","skipredirect_sblask-browser-action","_bd6be57d-91d7-41d2-b61d-3ba20f7942e5_-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"],"nav-bar":["back-button","stop-reload-button","forward-button","sync-button","alltabs-button","downloads-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","jid0-adyhmvsp91nuo8prv0mn2vkeb84_jetpack-browser-action","unified-extensions-button","sidebar-button","reset-pbm-toolbar-button","vertical-spacer"],"toolbar-menubar":["menubar-items"],"TabsToolbar":[],"vertical-tabs":["tabbrowser-tabs"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["developer-button","screenshot-button","ublock0_raymondhill_net-browser-action","reset-pbm-toolbar-button","languagetool-webextension_languagetool_org-browser-action","jid0-adyhmvsp91nuo8prv0mn2vkeb84_jetpack-browser-action","skipredirect_sblask-browser-action","_bd6be57d-91d7-41d2-b61d-3ba20f7942e5_-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"],"dirtyAreaCache":["nav-bar","vertical-tabs","PersonalToolbar","toolbar-menubar","TabsToolbar","unified-extensions-area"],"currentVersion":23,"newElementCount":8}'
);
// Desativa correção ortográfica (0 = desabilitado)
user_pref('layout.spellcheckDefault', 0);
// Não mostrar popup automático de tradução
user_pref('browser.translations.automaticallyPopup', false);
// Desativa completamente o recurso de tradução
user_pref('browser.translations.enable', false);

// === DNS OVER HTTPS (Quad9) ===
// Modo TRR (3 = apenas DoH, sem fallback para DNS normal)
user_pref('network.trr.mode', 3);
// URI do servidor DoH (Quad9)
user_pref('network.trr.uri', 'https://dns.quad9.net/dns-query');
// URI customizada do servidor DoH
user_pref('network.trr.custom_uri', 'https://dns.quad9.net/dns-query');
// Desabilita heurísticas automáticas de ativação do DoH
user_pref('doh-rollout.disable-heuristics', true);
// Marca primeira execução do DoH como concluída
user_pref('doh-rollout.doneFirstRun', true);
// Define região de origem (BR = Brasil)
user_pref('doh-rollout.home-region', 'BR');

// === BARRA DE ENDEREÇOS (URLBAR) - LIMPEZA ===
// Remove sugestões desnecessárias na barra de endereços
// Não sugerir motores de busca na URL bar
user_pref('browser.urlbar.suggest.engines', false);
// Não sugerir topsites na URL bar
user_pref('browser.urlbar.suggest.topsites', false);
// Não sugerir histórico na URL bar
user_pref('browser.urlbar.suggest.history', false);
// Não sugerir bookmarks na URL bar
user_pref('browser.urlbar.suggest.bookmark', false);
// Não sugerir páginas abertas na URL bar
user_pref('browser.urlbar.suggest.openpage', false);
// Não mostrar atalhos de bookmarks na URL bar
user_pref('browser.urlbar.shortcuts.bookmarks', false);
// Não mostrar atalhos de histórico na URL bar
user_pref('browser.urlbar.shortcuts.history', false);
// Não mostrar atalhos de abas na URL bar
user_pref('browser.urlbar.shortcuts.tabs', false);
// Não priorizar sugestões de busca na URL bar
user_pref('browser.urlbar.showSearchSuggestionsFirst', false);

// === OUTROS ===
// Bloqueia geolocalização por padrão (2 = bloquear)
user_pref('permissions.default.geo', 2);
// Bloqueia acesso à câmera por padrão (2 = bloquear)
user_pref('permissions.default.camera', 2);
// Bloqueia acesso ao microfone por padrão (2 = bloquear)
user_pref('permissions.default.microphone', 2);
// Bloqueia notificações desktop por padrão (2 = bloquear)
user_pref('permissions.default.desktop-notification', 2);
// Desabilita reprodução automática de mídia
// Política de autoplay (5 = bloquear)
user_pref('media.autoplay.default', 5);
// Política de bloqueio adicional de autoplay
user_pref('media.autoplay.blocking_policy', 2);
// Bloqueia acesso a dispositivos XR/VR por padrão (2 = bloquear)
user_pref('permissions.default.xr', 2);
// Provedor de geolocalização por rede
user_pref('geo.provider.network.url', 'https://beacondb.net/v1/geolocate');
// Não atualizar automaticamente motores de busca
user_pref('browser.search.update', false);
// URL padrão do permissions manager vazio
user_pref('permissions.manager.defaultsUrl', '');
// Desativa cache de getAddons
user_pref('extensions.getAddons.cache.enabled', false);
// Não fecha menu de bookmarks ao abrir em nova aba
user_pref('browser.bookmarks.openInTabClosesMenu', false);
// Remove botão de importar bookmarks (já executado)
user_pref('browser.bookmarks.addedImportButton', false);
// Local padrão dos favoritos (toolbar)
user_pref('browser.bookmarks.defaultLocation', 'toolbar_____');
// Idiomas aceitos pelo navegador (ordem de preferência)
user_pref('intl.accept_languages', 'pt-br,en-us,en');
// Bloqueia scripts que redimensionam ou movem a janela
user_pref('dom.disable_window_move_resize', true);

// === FASTFOX - PERFORMANCE TUNING ===

// GENERAL
// Tamanho do cache de fontes Skia (KB)
user_pref('gfx.content.skia-font-cache-size', 32);

// GFX
// Itens no cache acelerado do canvas
user_pref('gfx.canvas.accelerated.cache-items', 32768);
// Tamanho do cache acelerado do canvas (KB)
user_pref('gfx.canvas.accelerated.cache-size', 4096);
// Tamanho máximo permitido para WebGL
user_pref('webgl.max-size', 16384);

// DISK CACHE
// Desativa cache em disco
user_pref('browser.cache.disk.enable', false);

// MEMORY CACHE
// Se preferir o gerenciamento dinâmico (valor `-1`);
// Capacidade do cache em memória (KB)
user_pref('browser.cache.memory.capacity', 131072);
// Tamanho máximo por entrada no cache de memória (KB)
user_pref('browser.cache.memory.max_entry_size', 20480);
// Máximo de visualizadores de sessão em memória
user_pref('browser.sessionhistory.max_total_viewers', 4);
// Máximo de abas que podem ser desfeitas (undo)
user_pref('browser.sessionstore.max_tabs_undo', 10);

// MEDIA CACHE
// Tamanho máximo do cache de mídia (KB)
user_pref('media.memory_cache_max_size', 262144);
// Limite combinado dos caches de mídia (KB)
user_pref('media.memory_caches_combined_limit_kb', 1048576);
// Tempo de pré-leitura do cache de mídia (segundos)
user_pref('media.cache_readahead_limit', 600);
// Threshold para retomar cache de mídia (segundos)
user_pref('media.cache_resume_threshold', 300);

// IMAGE CACHE
// Tamanho do cache de imagens (bytes)
user_pref('image.cache.size', 10485760);
// Bytes decodificados por vez na decodificação de imagens
user_pref('image.mem.decode_bytes_at_a_time', 65536);

// NETWORK
// Número máximo de conexões HTTP
user_pref('network.http.max-connections', 1800);
// Máximo de conexões persistentes por servidor
user_pref('network.http.max-persistent-connections-per-server', 10);
// Limite de conexões urgentes por host
user_pref('network.http.max-urgent-start-excessive-connections-per-host', 5);
// Delay máximo de início de requisição (s)
user_pref('network.http.request.max-start-delay', 5);
// Desativa pacing de requisições HTTP
user_pref('network.http.pacing.requests.enabled', false);
// Entradas do cache DNS
user_pref('network.dnsCacheEntries', 10000);
// Tempo de expiração do cache DNS (s)
user_pref('network.dnsCacheExpiration', 3600);
// Capacidade do cache de tokens SSL
user_pref('network.ssl_tokens_cache_capacity', 10240);

// SPECULATIVE LOADING
// Desativa conexões especulativas paralelas
user_pref('network.http.speculative-parallel-limit', 0);
// Desativa prefetch de DNS
user_pref('network.dns.disablePrefetch', true);
// Desativa prefetch de DNS a partir de HTTPS
user_pref('network.dns.disablePrefetchFromHTTPS', true);
// Desativa conexões especulativas a partir da URL bar
user_pref('browser.urlbar.speculativeConnect.enabled', false);
// Desativa conexões especulativas de places
user_pref('browser.places.speculativeConnect.enabled', false);
// Desativa prefetch automático de páginas
user_pref('network.prefetch-next', false);
// Desativa o preditor de rede
user_pref('network.predictor.enabled', false);

// === SECUREFOX - PRIVACY & HARDENING ===

// TRACKING PROTECTION
// Categoria de bloqueio de conteúdo (strict = mais rigoroso)
user_pref('browser.contentblocking.category', 'strict');
// Mantém baseline da allow-list de tracking protection
user_pref('privacy.trackingprotection.allow_list.baseline.enabled', true);
// Iniciar downloads em diretório temporário
user_pref('browser.download.start_downloads_in_tmp_dir', true);
// Apagar arquivos temporários ao sair
user_pref('browser.helperApps.deleteTempFileOnExit', true);
// Desativa tutoriais interativos (UITour)
user_pref('browser.uitour.enabled', false);
// Habilita Global Privacy Control
user_pref('privacy.globalprivacycontrol.enabled', true);

// OCSP & CERTS / HPKP
// Desativa consultas OCSP (0 = desativado)
user_pref('security.OCSP.enabled', 0);
// Desativa relatório de CSP
user_pref('security.csp.reporting.enabled', false);

// SSL / TLS
// Tratar negociações TLS inseguras como quebradas
user_pref('security.ssl.treat_unsafe_negotiation_as_broken', true);
// Mostrar página especialista para certificados inválidos
user_pref('browser.xul.error_pages.expert_bad_cert', true);
// Desativa 0-RTT em TLS
user_pref('security.tls.enable_0rtt_data', false);

// DISK AVOIDANCE
// Forçar cache de mídia em memória no modo privado
user_pref('browser.privatebrowsing.forceMediaMemoryCache', true);
// Intervalo de gravação do sessionstore (ms)
user_pref('browser.sessionstore.interval', 60000);

// SHUTDOWN & SANITIZING
// Usar histórico de sanitização customizado
user_pref('privacy.history.custom', true);
// Reset do PBM quando apropriado
user_pref('browser.privatebrowsing.resetPBM.enabled', true);

// SEARCH / URL BAR
// Ocultar 'https://' na barra, mas reexibir após interação
user_pref('browser.urlbar.trimHttps', true);
// Reexibe URL completa ao interagir
user_pref('browser.urlbar.untrimOnUserInteraction.featureGate', true);
// Separar busca padrão da privada na UI
user_pref('browser.search.separatePrivateDefault.ui.enabled', true);
// Desativa sugestões de busca
user_pref('browser.search.suggest.enabled', false);
// Desativa QuickSuggest
user_pref('browser.urlbar.quicksuggest.enabled', false);
// Desativa rótulos de grupos na URL bar
user_pref('browser.urlbar.groupLabels.enabled', false);
// Desativa preenchimento automático de formulários
user_pref('browser.formfill.enable', false);
// Mostra punycode para IDNs
user_pref('network.IDN_show_punycode', true);

// PASSWORDS
// Desativa captura de senhas sem formulário
user_pref('signon.formlessCapture.enabled', false);
// Desativa captura de senhas em navegação privada
user_pref('signon.privateBrowsingCapture.enabled', false);
// Permite autenticação HTTP em subresources
user_pref('network.auth.subresource-http-auth-allow', 1);
// Não truncar colagens do usuário em editores
user_pref('editor.truncate_user_pastes', false);

// MIXED CONTENT + CROSS-SITE
// Bloqueia conteúdo misto de exibição
user_pref('security.mixed_content.block_display_content', true);
// Desativa scripting em PDF (segurança)
user_pref('pdfjs.enableScripting', false);

// EXTENSIONS
// Escopos permitidos para extensões instaladas
user_pref('extensions.enabledScopes', 5);

// HEADERS / REFERERS
// Política de trimming do referer entre origens
user_pref('network.http.referer.XOriginTrimmingPolicy', 2);

// CONTAINERS
// Habilita UI para Containers (userContext)
user_pref('privacy.userContext.ui.enabled', true);

// SAFE BROWSING
// Desativa verificação remota de downloads (Safe Browsing)
user_pref('browser.safebrowsing.downloads.remote.enabled', false);

// MOZILLA

// TELEMETRY
// Desativa envio de dados de telemetria
user_pref('datareporting.policy.dataSubmissionEnabled', false);
// Desativa upload do healthreport
user_pref('datareporting.healthreport.uploadEnabled', false);
// Desativa telemetria unificada
user_pref('toolkit.telemetry.unified', false);
// Desativa telemetria principal
user_pref('toolkit.telemetry.enabled', false);
// Servidor de telemetria neutro
user_pref('toolkit.telemetry.server', 'data:,');
// Desativa arquivamento de telemetria
user_pref('toolkit.telemetry.archive.enabled', false);
// Desativa ping de novo perfil
user_pref('toolkit.telemetry.newProfilePing.enabled', false);
// Desativa envio de ping no shutdown
user_pref('toolkit.telemetry.shutdownPingSender.enabled', false);
// Desativa pings de update
user_pref('toolkit.telemetry.updatePing.enabled', false);
// Desativa BHR ping
user_pref('toolkit.telemetry.bhrPing.enabled', false);
// Desativa firstShutdown ping
user_pref('toolkit.telemetry.firstShutdownPing.enabled', false);
// Opt-out de coverage telemetry
user_pref('toolkit.telemetry.coverage.opt-out', true);
user_pref('toolkit.coverage.opt-out', true);
// Endpoint de coverage vazio
user_pref('toolkit.coverage.endpoint.base', '');
// Desativa telemetria na newtab
user_pref('browser.newtabpage.activity-stream.feeds.telemetry', false);
user_pref('browser.newtabpage.activity-stream.telemetry', false);
// Desativa upload de uso
user_pref('datareporting.usage.uploadEnabled', false);

// EXPERIMENTS
// Desativa estudos e experiments (Shield/Normandy)
user_pref('app.shield.optoutstudies.enabled', false);
user_pref('app.normandy.enabled', false);
// API URL do Normandy vazio
user_pref('app.normandy.api_url', '');

// CRASH REPORTS
// URL de envio de crash reports vazia
user_pref('breakpad.reportURL', '');
// Não enviar relatórios de crash de abas
user_pref('browser.tabs.crashReporting.sendReport', false);

// === PESKYFOX - UI & MISC ===
// MOZILLA UI
// URL de promoção de VPN no PBM (vazio)
user_pref('browser.privatebrowsing.vpnpromourl', '');
// Não mostrar painel de obter complementos
user_pref('extensions.getAddons.showPane', false);
// Desativa recomendações de extensões
user_pref('extensions.htmlaboutaddons.recommendations.enabled', false);
// Desativa descoberta automática de recursos/addons
user_pref('browser.discovery.enabled', false);
// Não checar se o navegador é padrão
user_pref('browser.shell.checkDefaultBrowser', false);
// Desativa CFR (recommendations) para addons
user_pref(
  'browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons',
  false
);
// Desativa CFR (recommendations) para features
user_pref(
  'browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features',
  false
);
// Não mostrar mais conteúdos da Mozilla nas preferências
user_pref('browser.preferences.moreFromMozilla', false);
// Remover aviso do about:config
user_pref('browser.aboutConfig.showWarning', false);
// Desativa a tela de boas-vindas
user_pref('browser.aboutwelcome.enabled', false);
// Habilita múltiplos perfis
user_pref('browser.profiles.enabled', true);

// === THEME ADJUSTMENTS ===
// Mostra opção de modo compacto
user_pref('browser.compactmode.show', true);
// Desativa separação de janelas privadas na UI
user_pref('browser.privateWindowSeparation.enabled', false);

// === AI ===
// Desativa recursos de machine learning no navegador
user_pref('browser.ml.enable', false);
// Desativa chat com IA integrado
user_pref('browser.ml.chat.enabled', false);
// Remove menu de chat com IA
user_pref('browser.ml.chat.menu', false);
// Desativa agrupamento inteligente de abas
user_pref('browser.tabs.groups.smart.enabled', false);
// Desativa preview de links com IA
user_pref('browser.ml.linkPreview.enabled', false);

// === FULLSCREEN NOTICE ===
// Remove animação ao entrar em fullscreen
user_pref('full-screen-api.transition-duration.enter', '0 0');
// Remove animação ao sair do fullscreen
user_pref('full-screen-api.transition-duration.leave', '0 0');
// Timeout da mensagem de fullscreen (0 = imediato)
user_pref('full-screen-api.warning.timeout', 0);

// === URL BAR ===
// Desativa funcionalidade de trending na URL bar
user_pref('browser.urlbar.trending.featureGate', false);

// === NEW TAB PAGE ===
// Sites padrão da nova aba (lista vazia)
user_pref('browser.newtabpage.activity-stream.default.sites', '');
// Não mostrar Sponsored Top Sites
user_pref('browser.newtabpage.activity-stream.showSponsoredTopSites', false);
// Desativa seção Top Stories
user_pref('browser.newtabpage.activity-stream.feeds.section.topstories', false);
// Não mostrar conteúdo patrocinado
user_pref('browser.newtabpage.activity-stream.showSponsored', false);
// Desativa checkboxes de conteúdo patrocinado
user_pref('browser.newtabpage.activity-stream.showSponsoredCheckboxes', false);

// === DOWNLOADS ===
// Não adicionar downloads ao 'Recent Documents' do sistema
user_pref('browser.download.manager.addToRecentDocs', false);

// === PDF ===
// Abrir PDFs dentro do navegador (inline)
user_pref('browser.download.open_pdf_attachments_inline', true);

// === TAB BEHAVIOR ===
// Não fechar menu de bookmarks ao abrir em nova aba
user_pref('browser.bookmarks.openInTabClosesMenu', false);
// Mostrar opção 'Ver info da imagem' no menu
user_pref('browser.menu.showViewImageInfo', true);
// Destacar todas as ocorrências na findbar
user_pref('findbar.highlightAll', true);
// Não consumir espaço ao selecionar palavra seguinte
user_pref('layout.word_select.eat_space_to_next_word', false);
// Desenhar abas na barra de título
user_pref('browser.tabs.drawInTitlebar', false);
