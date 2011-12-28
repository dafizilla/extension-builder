# https://developer.mozilla.org/en/Setting_up_extension_development_environment#Development_preferences
echo >>$1/prefs.js 'user_pref("browser.dom.window.dump.enabled", true);'
echo >>$1/prefs.js 'user_pref("javascript.options.showInConsole", true);'
echo >>$1/prefs.js 'user_pref("javascript.options.strict", true);'
echo >>$1/prefs.js 'user_pref("nglayout.debug.disable_xul_cache", true);'
echo >>$1/prefs.js 'user_pref("extensions.logging.enabled", true);'
echo >>$1/prefs.js 'user_pref("nglayout.debug.disable_xul_fastload", true);'
echo >>$1/prefs.js 'user_pref("dom.report_all_js_exceptions", true);'

#cat >>$1/prefs.js /opt/devel/0dafiprj/srcmoz/release/prefs.js
