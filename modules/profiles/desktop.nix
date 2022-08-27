{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "desktop") {
    services.pcscd.enable = true;

    sconfig = {
      alacritty.enable = true;
      security-tools = true;
    };

    services.udev.extraHwdb = ''
      mouse:usb:*
        MOUSE_DPI=600@1000
    '';

    fonts.fonts = [ pkgs.bck-nerdfont ];

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

      (mpv-with-scripts.override { scripts = [ mpvScripts.mpris ]; })

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          ms-azuretools.vscode-docker
          ms-python.python
          shardulm94.trailing-spaces
        ] ++
        optionals config.sconfig.xmonad.enable [
          vscode-extensions.haskell.haskell
          vscode-extensions.justusadam.language-haskell
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

          Preferences = builtins.mapAttrs
            (n: v: { Value = v; Status = "locked"; })
            {
              "browser.contentblocking.category" = "strict";
              "browser.zoom.siteSpecific" = false;
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
              "network.IDN_show_punycode" = true;
              "ui.key.menuAccessKeyFocuses" = false;
            };

        };
      })

    ] ++
    optionals config.sconfig.xmonad.enable [
      haskell-language-server
    ];

    sconfig.user-settings = ''
      mkdir -p ~/.config/VSCodium/User
      ln -sf /etc/vscode-settings.json ~/.config/VSCodium/User/settings.json
      ln -sf /etc/vscode-keybindings.json ~/.config/VSCodium/User/keybindings.json
    '';

    environment.etc."vscode-settings.json".text = builtins.toJSON {
      "editor.cursorSurroundingLines" = 9;
      "editor.renderFinalNewline" = false;
      "editor.scrollBeyondLastLine" = false;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.watcherExclude"."**/result/**" = true;
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "python.formatting.autopep8Args" = [ "--max-line-length=999" ];
      "security.workspace.trust.banner" = "never";
      "security.workspace.trust.startupPrompt" = "never";
      "security.workspace.trust.untrustedFiles" = "newWindow";
      "terminal.external.linuxExec" = "x-terminal-emulator";
      "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font";
      "terminal.integrated.fontSize" = 16;
      "terminal.integrated.minimumContrastRatio" = 1;
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

    virtualisation.podman.enable = true;

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.loader.timeout = 1;
  };
}
