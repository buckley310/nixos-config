{ config, pkgs, lib, ... }:
with lib;
let
  pkcslib = "${pkgs.opensc}/lib/opensc-pkcs11.so";
in
{
  config = mkIf (config.sconfig.profile == "desktop") {
    services.pcscd.enable = true;
    programs.ssh.startAgent = true;
    programs.ssh.agentPKCS11Whitelist = pkcslib;

    sconfig.alacritty.enable = true;

    fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; }) ];

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
      element-desktop
      ffmpeg
      gimp
      glxinfo
      gnome3.dconf-editor
      opensc
      pavucontrol
      qemu_full
      steam-run
      tdesktop
      youtube-dl

      (pkgs.writeShellScriptBin "mfa" "exec ssh-add -s${pkcslib}")

      (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with pkgs.vscode-extensions; [
          # package was renamed from "Nix" to "nix" between 21.05 and 21.11
          (if (builtins.elem "nix" (builtins.attrNames bbenoist)) then bbenoist.nix else bbenoist.Nix)
          # ms-python.python
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
        "python.formatting.autopep8Args" = [ "--max-line-length=999" ];
        "python.showStartPage" = false;
        "security.workspace.trust.banner" = "never";
        "security.workspace.trust.startupPrompt" = "never";
        "security.workspace.trust.untrustedFiles" = "newWindow";
        "terminal.external.linuxExec" = "x-terminal-emulator";
        "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font";
        "terminal.integrated.fontSize" = 16;
        "terminal.integrated.showExitAlert" = false;
        "update.mode" = "none";
        "update.showReleaseNotes" = false;
        "window.menuBarVisibility" = "hidden";
        "workbench.startupEditor" = "none";
      };

    programs.steam.enable = true;

    virtualisation.docker = { enable = true; enableOnBoot = false; };

    boot.kernelPackages = pkgs.linuxPackages_5_14;

    boot.loader.timeout =
      if config.boot.loader.systemd-boot.enable
      then null else lib.mkOverride 9999 99;
  };
}
