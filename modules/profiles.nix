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
      services.openssh.startWhenNeeded = true;
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
        tdesktop
        element-desktop
        pavucontrol
        gnome3.dconf-editor
        glxinfo
        steam-run

        pkgs.opensc
        (pkgs.writeShellScriptBin "mfa" "exec ssh-add -s${pkcslib}")

        (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })

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

      environment.etc."vscode-user-settings.json".text =
        "//usr/bin/env ln -sf $0 ~/.config/VSCodium/User/settings.json; exit 0"
        + "\n" + builtins.toJSON {
          "editor.renderFinalNewline" = false;
          "editor.scrollBeyondLastLine" = false;
          "extensions.autoCheckUpdates" = false;
          "extensions.autoUpdate" = false;
          "files.insertFinalNewline" = true;
          "files.trimFinalNewlines" = true;
          "git.confirmSync" = false;
          "python.showStartPage" = false;
          "security.workspace.trust.banner" = "never";
          "security.workspace.trust.startupPrompt" = "never";
          "security.workspace.trust.untrustedFiles" = "newWindow";
          "terminal.integrated.fontFamily" = "Liberation Mono";
          "update.mode" = "none";
          "update.showReleaseNotes" = false;
          "window.menuBarVisibility" = "hidden";
          "workbench.startupEditor" = "none";
        };

      programs.steam.enable = true;

      virtualisation.docker = { enable = true; enableOnBoot = false; };

      boot.loader.timeout =
        if config.boot.loader.systemd-boot.enable
        then null else lib.mkOverride 9999 99;
    })


  ];
}
