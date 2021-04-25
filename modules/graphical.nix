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
      forceWayland = true;
      extraPolicies = {
        CaptivePortal = false;
        DisablePocket = true;
        DisableFirefoxStudies = true;
        OfferToSaveLogins = false;
        DisableFormHistory = true;
        SearchSuggestEnabled = false;
        Preferences = {
          "dom.security.https_only_mode" = { Status = "locked"; Value = true; };
          "extensions.formautofill.available" = { Status = "locked"; Value = "off"; };
          "browser.contentblocking.category" = { Status = "locked"; Value = "strict"; };
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
