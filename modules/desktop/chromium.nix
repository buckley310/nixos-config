{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.sconfig.desktop.enable) {
    environment.systemPackages = [
      pkgs.brave
    ];
    programs.chromium = {
      enable = true;
      extraOpts = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        BlockThirdPartyCookies = true;
        BrowserAddPersonEnabled = false;
        BrowserGuestModeEnabled = false;
        BrowserLabsEnabled = false;
        DefaultGeolocationSetting = 2;
        DefaultNotificationsSetting = 2;
        ExtensionInstallBlocklist = [ "*" ];
        ExtensionInstallForcelist = [
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        ];
        NetworkPredictionOptions = 2;
        PasswordManagerEnabled = false;
        ShowFullUrlsInAddressBar = true;
        SyncDisabled = true; # required for BrowsingDataLifetime
        BrowsingDataLifetime = [
          {
            data_types = [ "browsing_history" ];
            time_to_live_in_hours = 24 * 30;
          }
          {
            data_types = [ "download_history" ];
            time_to_live_in_hours = 12;
          }
        ];
      };
    };
  };
}
