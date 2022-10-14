{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "desktop") {
    services.pcscd.enable = true;

    sconfig = {
      alacritty.enable = true;
      security-tools = true;
      pipewire = true;
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
        ];
      })

      (wrapFirefox firefox-unwrapped {
        extraPolicies = {
          NewTabPage = false;
          CaptivePortal = false;
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

      (pkgs.writeShellScriptBin "my-dash-to-panel" ''
        dconf write /org/gnome/shell/extensions/dash-to-panel/group-apps false
        dconf write /org/gnome/shell/extensions/dash-to-panel/isolate-workspaces true
        dconf write /org/gnome/shell/extensions/dash-to-panel/panel-positions "'{\"0\":\"TOP\"}'"
        dconf write /org/gnome/shell/extensions/dash-to-panel/panel-sizes "'{\"0\":40}'"
        dconf write /org/gnome/shell/extensions/dash-to-panel/show-window-previews false
      '')

    ];

    sconfig.user-settings = ''
      mkdir -p ~/.config/VSCodium/User
      ln -sf /etc/vscode-settings.json ~/.config/VSCodium/User/settings.json
      ln -sf /etc/vscode-keybindings.json ~/.config/VSCodium/User/keybindings.json
    '';

    environment.etc."vscode-settings.json".text = builtins.toJSON {
      "diffEditor.renderSideBySide" = false;
      "editor.cursorSurroundingLines" = 9;
      "editor.renderFinalNewline" = false;
      "editor.scrollBeyondLastLine" = false;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      "files.watcherExclude"."**/result/**" = true;
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "python.formatting.provider" = "black";
      "security.workspace.trust.banner" = "never";
      "security.workspace.trust.startupPrompt" = "never";
      "security.workspace.trust.untrustedFiles" = "newWindow";
      "terminal.external.linuxExec" = "x-terminal-emulator";
      "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font";
      "terminal.integrated.fontSize" = 16;
      "terminal.integrated.minimumContrastRatio" = 1;
      "terminal.integrated.shellIntegration.enabled" = false;
      "terminal.integrated.showExitAlert" = false;
      "trailing-spaces.highlightCurrentLine" = false;
      "update.showReleaseNotes" = false;
      "window.menuBarVisibility" = "hidden";
      "workbench.startupEditor" = "none";

      # NixOS specific vscode settings, do not copy to other operating systems:
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "update.mode" = "none";
    };

    environment.etc."vscode-keybindings.json".text = builtins.toJSON [
      { key = "ctrl+w"; command = "-workbench.action.terminal.killEditor"; }
      { key = "ctrl+e"; command = "-workbench.action.quickOpen"; }
      { key = "ctrl+e"; command = "workbench.action.quickOpen"; when = "!terminalFocus"; }
    ];

    boot.loader.timeout = 1;
  };
}
