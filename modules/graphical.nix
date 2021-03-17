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
        Preferences = {
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

  services.flatpak.enable = true;

  hardware.pulseaudio.enable = true;

  boot.loader.timeout = null;
}
