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

    fonts.fonts = [
      # vscode: "DejaVuSansMono Nerd Font Mono" (size 16)
      # gnome-terminal: "DejaVu Sans Mono, Inconsolata for Powerline Medium 12"
      # gnome-terminal setting (dconf): /org/gnome/terminal/legacy/profiles/.../font
      pkgs.powerline-fonts
      (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
    ];

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
      chromium
      discord
      element-desktop
      ffmpeg
      gimp
      glxinfo
      gnome3.dconf-editor
      opensc
      pavucontrol
      pulseeffects-legacy
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

    sconfig.user-settings = ''
      ln -sf /etc/vscode-settings.json ~/.config/VSCodium/User/settings.json
      ln -sf /etc/vscode-keybindings.json ~/.config/VSCodium/User/keybindings.json
    '';

    environment.etc."vscode-settings.json".text = builtins.toJSON {
      "editor.renderFinalNewline" = false;
      "editor.scrollBeyondLastLine" = false;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.watcherExclude"."**/result/**" = true;
      "git.confirmSync" = false;
      "python.formatting.autopep8Args" = [ "--max-line-length=999" ];
      "python.showStartPage" = false;
      "security.workspace.trust.banner" = "never";
      "security.workspace.trust.startupPrompt" = "never";
      "security.workspace.trust.untrustedFiles" = "newWindow";
      "terminal.external.linuxExec" = "x-terminal-emulator";
      "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font Mono";
      "terminal.integrated.fontSize" = 16;
      "terminal.integrated.showExitAlert" = false;
      "update.mode" = "none";
      "update.showReleaseNotes" = false;
      "window.menuBarVisibility" = "hidden";
      "workbench.startupEditor" = "none";
      "terminal.integrated.profiles.linux"."bash" = {
        "path" = "bash";
        "args" = [ "-c" "unset SHLVL; bash" ];
      };
    };

    environment.etc."vscode-keybindings.json".text = builtins.toJSON [
      { key = "ctrl+w"; command = "-workbench.action.terminal.killEditor"; }
      { key = "ctrl+e"; command = "-workbench.action.quickOpen"; }
      { key = "ctrl+e"; command = "workbench.action.quickOpen"; when = "!terminalFocus"; }
    ];

    programs.steam.enable = true;

    virtualisation.docker = { enable = true; enableOnBoot = false; };

    boot.kernelPackages = pkgs.linuxPackages_5_14;

    boot.loader.timeout =
      if config.boot.loader.systemd-boot.enable
      then null else lib.mkOverride 9999 99;
  };
}
