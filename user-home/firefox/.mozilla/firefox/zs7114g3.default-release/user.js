/* CUSTOMIZAÇÃO DE UI & TEMAS */

/*
 * Arquivo organizado por seção. Verifiquei duplicatas e mantive
 * as definições nas seções específicas (p.ex. FASTFOX, SECUREFOX,
 * PESKYFOX). Onde havia valores conflitantes, o valor final do
 * arquivo (a ocorrência mais abaixo) foi preservado — Firefox
 * aplica a última ocorrência em um `user.js`.
 */

// Habilita o carregamento de userChrome.css e userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true)
// Força tema não nativo (útil para consistência visual no Linux)
user_pref("widget.non-native-theme.enabled", true)
// Habilita abas verticais e nova barra lateral
user_pref("sidebar.verticalTabs", true)
user_pref("sidebar.revamp", true)
user_pref("sidebar.visibility", "hide-sidebar") // Começa oculto ou conforme estado
// Remove o título da janela quando as abas estão na barra de título
user_pref("browser.tabs.inTitlebar", 1)

/* PERFORMANCE & HARDWARE (VA-API/Intel) */
// Força aceleração WebRender
user_pref("gfx.webrender.all", true)
// Força aceleração de camadas
user_pref("layers.acceleration.force-enabled", false)
// Habilita decodificação de vídeo por hardware (VA-API)
user_pref("media.ffmpeg.vaapi.enabled", true)
user_pref("media.hardware-video-decoding.force-enabled", false)
// Desabilita FFVPX para forçar o uso de decodificadores do sistema
user_pref("media.ffvpx.enabled", false)
// Força o uso de cache na RAM
user_pref("browser.cache.memory.enable", true)

/* PRIVACIDADE & SEGURANÇA */

user_pref("toolkit.telemetry.reportingpolicy.firstRun", false)

user_pref("privacy.fingerprintingProtection", true)
// Força modo HTTPS-Only
user_pref("dom.security.https_only_mode", true)

/* LIMPEZA E COMPORTAMENTO */
// Não salvar senhas no navegador
user_pref("signon.rememberSignons", false)
// Limpar dados ao fechar (conforme seu prefs.js)
user_pref("privacy.sanitize.sanitizeOnShutdown", true)
user_pref("privacy.clearOnShutdown.cookies", false) // Você definiu false, mantendo login
user_pref("privacy.clearOnShutdown.sessions", false) // Mantém sessões abertas
user_pref("privacy.clearOnShutdown_v2.formdata", true) // Limpa dados de formulário
user_pref("privacy.clearSiteData.browsingHistoryAndDownloads", true)

/* BARRA DE ENDEREÇOS (URLBAR) LIMPA */
// Remove sugestões desnecessárias na barra de endereços
user_pref("browser.urlbar.suggest.engines", false)
user_pref("browser.urlbar.suggest.topsites", false)
user_pref("browser.urlbar.suggest.history", false)
user_pref("browser.urlbar.suggest.bookmark", false)
user_pref("browser.urlbar.suggest.openpage", false)
user_pref("browser.urlbar.shortcuts.bookmarks", false)
user_pref("browser.urlbar.shortcuts.history", false)
user_pref("browser.urlbar.shortcuts.tabs", false)
user_pref("browser.urlbar.showSearchSuggestionsFirst", false)

/* OUTROS */
// Desabilita reprodução automática de mídia
user_pref("media.autoplay.default", 5)
user_pref("media.autoplay.blocking_policy", 2)
// Impede que o navegador verifique se é o padrão na inicialização

// Define localização padrão dos favoritos
user_pref("browser.bookmarks.defaultLocation", "toolbar_____")
// Idioma
user_pref("intl.accept_languages", "pt-br,en-us,en")
// Impede que sites mexam no tamanho da sua janela ou movam ela
user_pref("dom.disable_window_move_resize", true)

/****************************************************************************
 * SECTION: FASTFOX                                                         *
 ****************************************************************************/
/** GENERAL ***/
user_pref("gfx.content.skia-font-cache-size", 32)

/** GFX ***/
user_pref("gfx.canvas.accelerated.cache-items", 32768)
user_pref("gfx.canvas.accelerated.cache-size", 4096)
user_pref("webgl.max-size", 16384)

/** DISK CACHE ***/
user_pref("browser.cache.disk.enable", false)

/** MEMORY CACHE ***/
// Nota: mantive `browser.cache.memory.capacity = 131072` nesta seção
// (valor de FASTFOX). Se preferir o gerenciamento dinâmico (valor `-1`),
// posso ajustar — por enquanto preservei o valor explícito usado aqui.
user_pref("browser.cache.memory.capacity", 131072)
user_pref("browser.cache.memory.max_entry_size", 20480)
user_pref("browser.sessionhistory.max_total_viewers", 4)
user_pref("browser.sessionstore.max_tabs_undo", 10)

/** MEDIA CACHE ***/
user_pref("media.memory_cache_max_size", 262144)
user_pref("media.memory_caches_combined_limit_kb", 1048576)
user_pref("media.cache_readahead_limit", 600)
user_pref("media.cache_resume_threshold", 300)

/** IMAGE CACHE ***/
user_pref("image.cache.size", 10485760)
user_pref("image.mem.decode_bytes_at_a_time", 65536)

/** NETWORK ***/
user_pref("network.http.max-connections", 1800)
user_pref("network.http.max-persistent-connections-per-server", 10)
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5)
user_pref("network.http.request.max-start-delay", 5)
user_pref("network.http.pacing.requests.enabled", false)
user_pref("network.dnsCacheEntries", 10000)
user_pref("network.dnsCacheExpiration", 3600)
user_pref("network.ssl_tokens_cache_capacity", 10240)

/** SPECULATIVE LOADING ***/
user_pref("network.http.speculative-parallel-limit", 0)
user_pref("network.dns.disablePrefetch", true)
user_pref("network.dns.disablePrefetchFromHTTPS", true)
user_pref("browser.urlbar.speculativeConnect.enabled", false)
user_pref("browser.places.speculativeConnect.enabled", false)
user_pref("network.prefetch-next", false)
user_pref("network.predictor.enabled", false)

/****************************************************************************
 * SECTION: SECUREFOX                                                       *
 ****************************************************************************/
/** TRACKING PROTECTION ***/
user_pref("browser.contentblocking.category", "strict")
user_pref("privacy.trackingprotection.allow_list.baseline.enabled", true)
user_pref("browser.download.start_downloads_in_tmp_dir", true)
user_pref("browser.helperApps.deleteTempFileOnExit", true)
user_pref("browser.uitour.enabled", false)
user_pref("privacy.globalprivacycontrol.enabled", true)

/** OCSP & CERTS / HPKP ***/
user_pref("security.OCSP.enabled", 0)
user_pref("security.csp.reporting.enabled", false)

/** SSL / TLS ***/
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true)
user_pref("browser.xul.error_pages.expert_bad_cert", true)
user_pref("security.tls.enable_0rtt_data", false)

/** DISK AVOIDANCE ***/
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true)
user_pref("browser.sessionstore.interval", 60000)

/** SHUTDOWN & SANITIZING ***/
user_pref("privacy.history.custom", true)
user_pref("browser.privatebrowsing.resetPBM.enabled", true)

/** SEARCH / URL BAR ***/
user_pref("browser.urlbar.trimHttps", true)
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true)
user_pref("browser.search.separatePrivateDefault.ui.enabled", true)
user_pref("browser.search.suggest.enabled", false)
user_pref("browser.urlbar.quicksuggest.enabled", false)
user_pref("browser.urlbar.groupLabels.enabled", false)
user_pref("browser.formfill.enable", false)
user_pref("network.IDN_show_punycode", true)

/** PASSWORDS ***/
user_pref("signon.formlessCapture.enabled", false)
user_pref("signon.privateBrowsingCapture.enabled", false)
user_pref("network.auth.subresource-http-auth-allow", 1)
user_pref("editor.truncate_user_pastes", false)

/** MIXED CONTENT + CROSS-SITE ***/
user_pref("security.mixed_content.block_display_content", true)
user_pref("pdfjs.enableScripting", false)

/** EXTENSIONS ***/
user_pref("extensions.enabledScopes", 5)

/** HEADERS / REFERERS ***/
user_pref("network.http.referer.XOriginTrimmingPolicy", 2)

/** CONTAINERS ***/
user_pref("privacy.userContext.ui.enabled", true)

/** SAFE BROWSING ***/
user_pref("browser.safebrowsing.downloads.remote.enabled", false)

/** MOZILLA ***/
user_pref("permissions.default.desktop-notification", 2)
user_pref("permissions.default.geo", 2)
user_pref("geo.provider.network.url", "https://beacondb.net/v1/geolocate")
user_pref("browser.search.update", false)
user_pref("permissions.manager.defaultsUrl", "")
user_pref("extensions.getAddons.cache.enabled", false)

/** TELEMETRY ***/
// Telemetria e uploads desativados intencionalmente — configurado
// de forma conservadora em SECUREFOX para privacidade máxima.
user_pref("datareporting.policy.dataSubmissionEnabled", false)
user_pref("datareporting.healthreport.uploadEnabled", false)
user_pref("toolkit.telemetry.unified", false)
user_pref("toolkit.telemetry.enabled", false)
user_pref("toolkit.telemetry.server", "data:,")
user_pref("toolkit.telemetry.archive.enabled", false)
user_pref("toolkit.telemetry.newProfilePing.enabled", false)
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false)
user_pref("toolkit.telemetry.updatePing.enabled", false)
user_pref("toolkit.telemetry.bhrPing.enabled", false)
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false)
user_pref("toolkit.telemetry.coverage.opt-out", true)
user_pref("toolkit.coverage.opt-out", true)
user_pref("toolkit.coverage.endpoint.base", "")
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false)
user_pref("browser.newtabpage.activity-stream.telemetry", false)
user_pref("datareporting.usage.uploadEnabled", false)

/** EXPERIMENTS ***/
user_pref("app.shield.optoutstudies.enabled", false)
user_pref("app.normandy.enabled", false)
user_pref("app.normandy.api_url", "")

/** CRASH REPORTS ***/
user_pref("breakpad.reportURL", "")
user_pref("browser.tabs.crashReporting.sendReport", false)

/****************************************************************************
 * SECTION: PESKYFOX                                                        *
 ****************************************************************************/
/** MOZILLA UI ***/
user_pref("browser.privatebrowsing.vpnpromourl", "")
user_pref("extensions.getAddons.showPane", false)
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false)
user_pref("browser.discovery.enabled", false)
user_pref("browser.shell.checkDefaultBrowser", false)
user_pref(
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons",
  false
)
user_pref(
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features",
  false
)
user_pref("browser.preferences.moreFromMozilla", false)
user_pref("browser.aboutConfig.showWarning", false)
user_pref("browser.aboutwelcome.enabled", false)
user_pref("browser.profiles.enabled", true)

/** THEME ADJUSTMENTS ***/
// Observação: o carregamento de `userChrome.css`/`userContent.css`
// está habilitado no topo do arquivo para permitir customizações.
user_pref("browser.compactmode.show", true)
user_pref("browser.privateWindowSeparation.enabled", false) // WINDOWS

/** AI ***/
user_pref("browser.ml.enable", false)
user_pref("browser.ml.chat.enabled", false)
user_pref("browser.ml.chat.menu", false)
user_pref("browser.tabs.groups.smart.enabled", false)
user_pref("browser.ml.linkPreview.enabled", false)

/** FULLSCREEN NOTICE ***/
user_pref("full-screen-api.transition-duration.enter", "0 0")
user_pref("full-screen-api.transition-duration.leave", "0 0")
user_pref("full-screen-api.warning.timeout", 0)

/** URL BAR ***/
user_pref("browser.urlbar.trending.featureGate", false)

/** NEW TAB PAGE ***/
user_pref("browser.newtabpage.activity-stream.default.sites", "")
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false)
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false)
user_pref("browser.newtabpage.activity-stream.showSponsored", false)
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false)

/** DOWNLOADS ***/
user_pref("browser.download.manager.addToRecentDocs", false)

/** PDF ***/
user_pref("browser.download.open_pdf_attachments_inline", true)

/** TAB BEHAVIOR ***/
user_pref("browser.bookmarks.openInTabClosesMenu", false)
user_pref("browser.menu.showViewImageInfo", true)
user_pref("findbar.highlightAll", true)
user_pref("layout.word_select.eat_space_to_next_word", false)

user_pref("browser.tabs.drawInTitlebar", true)
