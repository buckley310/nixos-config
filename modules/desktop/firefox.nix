{ config, lib, pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        NewTabPage = false;
        CaptivePortal = false;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        OfferToSaveLogins = false;
        DisableFormHistory = true;
        SearchSuggestEnabled = false;
        Preferences = builtins.mapAttrs
          (n: v: { Value = v; Status = "locked"; })
          {
            "browser.aboutConfig.showWarning" = false;
            "browser.chrome.toolbar_tips" = false; # https://bugzilla.mozilla.org/show_bug.cgi?id=148624
            "browser.contentblocking.category" = "strict";
            "browser.zoom.siteSpecific" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "network.IDN_show_punycode" = true;
            "ui.key.menuAccessKeyFocuses" = false;
          };
        ExtensionSettings =
          { "*".installation_mode = "blocked"; } //
          builtins.mapAttrs
            (n: v: {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${v}/latest.xpi";
            })
            {
              "jid1-KKzOGWgsW3Ao4Q@jetpack" = "i-dont-care-about-cookies";
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            };
      };
    })
  ];
}
