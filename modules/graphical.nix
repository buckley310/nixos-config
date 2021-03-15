{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    gimp
    mpv
    tdesktop
    pavucontrol
    gnome3.dconf-editor
    glxinfo
    steam-run

    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
        ms-python.python
        ms-vscode.cpptools
        ms-azuretools.vscode-docker
      ];
    })

    (wrapFirefox firefox-unwrapped {
      extraPolicies = {
        CaptivePortal = false;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        OfferToSaveLogins = false;
        DisableFormHistory = true;
        SearchSuggestEnabled = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = {
          "extensions.formautofill.available" = { Status = "locked"; Value = "off"; };
          "network.cookie.cookieBehavior" = { Status = "locked"; Value = 4; };
          "network.IDN_show_punycode" = { Status = "locked"; Value = true; };
          "browser.zoom.siteSpecific" = { Status = "locked"; Value = false; };
        };
      };
    })

  ];

  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  programs.steam.enable = true;

  hardware.pulseaudio.enable = true;

  boot.loader.timeout = null;
}
