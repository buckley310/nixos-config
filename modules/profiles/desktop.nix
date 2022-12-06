{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.sconfig.profile == "desktop") {
    services.pcscd.enable = true;
    virtualisation.podman.enable = true;

    # Pipewire
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    sconfig = {
      alacritty.enable = true;
      security-tools = true;
    };

    services.udev.extraHwdb = ''
      mouse:usb:*
        MOUSE_DPI=600@1000
    '';

    fonts.fonts = [
      (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
    ];

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

      (mpv.override { scripts = [ mpvScripts.mpris ]; })

      (vscode-with-extensions.override {
        vscodeExtensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          ms-azuretools.vscode-docker
          ms-python.python
          redhat.vscode-yaml
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

    environment.etc."my-settings.sh".text = ''
      mkdir -p ~/.config/Code/User
      ln -sf /etc/vscode-settings.json ~/.config/Code/User/settings.json
      ln -sf /etc/vscode-keybindings.json ~/.config/Code/User/keybindings.json
    '';

    environment.etc."vscode-settings.json".text = builtins.toJSON (
      (
        builtins.fromJSON (builtins.readFile ./vscode-settings.json)
      ) // {
        # NixOS-specific vscode settings:
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "terminal.external.linuxExec" = "x-terminal-emulator";
        "terminal.integrated.fontFamily" = "DejaVuSansMono Nerd Font";
        "update.mode" = "none";
      }
    );

    environment.etc."vscode-keybindings.json".text = builtins.toJSON [
      { key = "ctrl+w"; command = "-workbench.action.terminal.killEditor"; }
      { key = "ctrl+e"; command = "-workbench.action.quickOpen"; }
      { key = "ctrl+e"; command = "workbench.action.quickOpen"; when = "!terminalFocus"; }
    ];

    boot.loader.timeout = 1;
  };
}
