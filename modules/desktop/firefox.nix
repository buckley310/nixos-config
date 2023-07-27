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
      };
    })
  ];
}
