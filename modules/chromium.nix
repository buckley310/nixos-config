{ config, pkgs, lib, ... }:
{
  nixpkgs.config.chromium.commandLineArgs = toString [
    "--enable-features=WebUIDarkMode"
    "--force-dark-mode"
  ];
  programs.chromium = {
    enable = true;
    extraOpts = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      BlockThirdPartyCookies = true;
      BrowserAddPersonEnabled = false;
      BrowserGuestModeEnabled = false;
      DefaultGeolocationSetting = 2;
      DefaultNotificationsSetting = 2;
      NetworkPredictionOptions = 2;
      PasswordManagerEnabled = false;
      SyncDisabled = true; # required for BrowsingDataLifetime
      BrowsingDataLifetime = [
        { data_types = [ "browsing_history" ]; time_to_live_in_hours = 24 * 7; }
        { data_types = [ "download_history" ]; time_to_live_in_hours = 6; }
      ];
    };
  };
}
