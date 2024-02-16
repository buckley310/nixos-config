{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.sconfig.desktop.enable) {
    environment.systemPackages = [
      (pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          NewTabPage = false;
          CaptivePortal = false;
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          OfferToSaveLogins = false;
          DisableFormHistory = true;
          SearchSuggestEnabled = false;
          Preferences = builtins.mapAttrs
            (n: v: { Value = v; Status = "locked"; })
            {
              "accessibility.force_disabled" = 1;
              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "strict";
              "browser.tabs.firefox-view" = false;
              "browser.uitour.enabled" = false;
              "browser.zoom.siteSpecific" = false;
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
              "extensions.formautofill.heuristics.enabled" = false;
              "network.IDN_show_punycode" = true;
              "places.history.expiration.max_pages" = 2048;
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
                "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
              };
        };
      })
    ];
  };
}
