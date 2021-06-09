{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig.profile;


  desktop-config = {
    environment.systemPackages = with pkgs; [
      brave
      gimp
      ffmpeg
      mpv
      tdesktop
      element-desktop
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
          Preferences = {
            "extensions.formautofill.available" = { Status = "locked"; Value = "off"; };
            "browser.contentblocking.category" = { Status = "locked"; Value = "strict"; };
            "network.IDN_show_punycode" = { Status = "locked"; Value = true; };
            "browser.zoom.siteSpecific" = { Status = "locked"; Value = false; };
          };
        };
      })

    ];

    programs.steam.enable = true;

    virtualisation.docker = { enable = true; enableOnBoot = false; };

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    boot.loader.timeout =
      if config.boot.loader.systemd-boot.enable
      then null else lib.mkOverride 9999 99;
  };


  server-config = {
    services.openssh.enable = true;
    documentation.nixos.enable = false;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };


in
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop" ];
  };

  config = { inherit desktop server; }."${cfg}-config";
}
