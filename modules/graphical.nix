{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    brave
    gimp
    mpv
    libreoffice
    tdesktop
    pavucontrol
    gnome3.dconf-editor
    glxinfo
    steam-run
    discord

    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
        ms-python.python
        ms-vscode.cpptools
        ms-azuretools.vscode-docker

        (vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "vscode-deno";
            publisher = "denoland";
            version = "2.3.3";
            sha256 = "1sirni7hamwp0dld5l8qw7jfrjxf3pvsmjrx14zvg2bwwrv4p0m6";
          };
        })

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
        };
      };
    })

  ];

  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove Lock = Caps_Lock"
    ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keysym Caps_Lock = F13"
  '';

  programs.steam.enable = true;

  hardware.pulseaudio.enable = true;

  boot.loader.timeout = null;
}
