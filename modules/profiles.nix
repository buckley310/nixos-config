{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.sconfig.profile;

  pkcslib = "${pkgs.opensc}/lib/opensc-pkcs11.so";

in
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop" ];
  };

  config = mkMerge [


    (mkIf (cfg == "server") {
      services.openssh.enable = true;
      documentation.nixos.enable = false;
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
    })


    (mkIf (cfg == "desktop") {
      services.pcscd.enable = true;
      programs.ssh.startAgent = true;
      programs.ssh.agentPKCS11Whitelist = pkcslib;

      nixpkgs.overlays = [
        (self: super: {
          gnome = super.gnome // {
            gnome-keyring = super.gnome.gnome-keyring.overrideAttrs (old: {
              configureFlags = old.configureFlags ++ [ "--disable-ssh-agent" ];
            });
          };
        })
      ];

      environment.systemPackages = with pkgs; [
        brave
        discord
        gimp
        ffmpeg
        youtube-dl
        mpv
        tdesktop
        element-desktop
        pavucontrol
        gnome3.dconf-editor
        glxinfo
        steam-run

        pkgs.opensc
        (pkgs.writeShellScriptBin "mfa" "exec ssh-add -s${pkcslib}")

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

      boot.loader.timeout =
        if config.boot.loader.systemd-boot.enable
        then null else lib.mkOverride 9999 99;
    })


  ];
}
