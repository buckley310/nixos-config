{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "desktop") {
    services.pcscd.enable = true;

    sconfig = {
      alacritty.enable = true;
      security-tools = true;
    };

    fonts.fonts = [ pkgs.bck-nerdfont ];

    environment.etc.nixpkgs.source = pkgs.nixpkgs_src;
    nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];

    environment.variables.MOZ_ENABLE_WAYLAND = "1";
    environment.variables.MOZ_USE_XINPUT2 = "1";

    environment.systemPackages = with pkgs; [
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
      tdesktop
      youtube-dl

      (writeShellScriptBin "nr" "exec nix repl ${pkgs.nixpkgs_src}")

      (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          ms-azuretools.vscode-docker
          ms-python.python
          shardulm94.trailing-spaces
        ];
      })

      (wrapFirefox firefox-unwrapped {
        extraPolicies = {
          NewTabPage = false;
          CaptivePortal = false;
          DisablePocket = true;
          DisableFirefoxStudies = true;
          OfferToSaveLogins = false;
          DisableFormHistory = true;
          SearchSuggestEnabled = false;
          Preferences = {
            "browser.contentblocking.category" = { Status = "locked"; Value = "strict"; };
            "browser.zoom.siteSpecific" = { Status = "locked"; Value = false; };
            "extensions.formautofill.available" = { Status = "locked"; Value = "off"; };
            "media.setsinkid.enabled" = { Status = "locked"; Value = true; }; #GoogleVoice
            "network.IDN_show_punycode" = { Status = "locked"; Value = true; };
            "ui.key.menuAccessKeyFocuses" = { Status = "locked"; Value = false; };
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
      "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font";
      "terminal.integrated.fontSize" = 16;
      "terminal.integrated.showExitAlert" = false;
      "trailing-spaces.highlightCurrentLine" = false;
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

    virtualisation.docker = { enable = true; enableOnBoot = false; };

    boot.kernelPackages = pkgs.linuxPackages_5_15;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    boot.loader.timeout =
      if config.boot.loader.systemd-boot.enable
      then null else lib.mkOverride 9999 99;
  };
}
