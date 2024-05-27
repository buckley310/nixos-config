{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.gnome;
in
{
  options.sconfig.gnome = lib.mkEnableOption "Enable Gnome Desktop";

  config = lib.mkIf cfg {

    services.libinput.enable = true;
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      displayManager.gdm.autoSuspend = false;
      desktopManager.gnome.enable = true;
    };

    services.colord.enable = false;

    systemd.services.packagekit.enable = false;

    environment.systemPackages = with pkgs; [
      gnome3.gnome-tweaks
      gnomeExtensions.appindicator

      (writeShellScriptBin "x-terminal-emulator" ''
        exec kitty "$@"
      '')

      (writeShellScriptBin "red" ''
        x="$(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled)"
        [ "$x" = "true" ] && x=false || x=true
        echo "Nightlight: $x"
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled $x
      '')
    ];

    environment.etc."my-settings.sh".text = ''
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      gsettings set org.gnome.desktop.interface enable-hot-corners false
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
      gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 12'
      gsettings set org.gnome.desktop.interface show-battery-percentage true
      gsettings set org.gnome.desktop.media-handling automount false
      gsettings set org.gnome.desktop.media-handling autorun-never true
      gsettings set org.gnome.desktop.notifications show-in-lock-screen false
      gsettings set org.gnome.desktop.privacy remove-old-temp-files true
      gsettings set org.gnome.desktop.privacy remove-old-trash-files true
      gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Epiphany.desktop']"
      gsettings set org.gnome.desktop.wm.keybindings maximize-vertically "['<Super>w']"
      gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"
      gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
      gsettings set org.gnome.settings-daemon.plugins.media-keys logout '[]'
      gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
    '';

  };
}
