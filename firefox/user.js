// Firefox — rice "Mucha"
// carrega chrome/userChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// interface clara, combinando com o resto do sistema
user_pref("layout.css.prefers-color-scheme.content-override", 1);
user_pref("browser.theme.toolbar-theme", 1);
user_pref("browser.theme.content-theme", 1);
// tema padrão (segue o sistema claro) em vez de um tema leve escuro
user_pref("extensions.activeThemeID", "default-theme@mozilla.org");
