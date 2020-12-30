{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      numix-icon-theme
      gnome3.gnome-tweaks
      gnome3.gnome-boxes
      qemu_kvm
      (writeShellScriptBin "red" ''
        x="$(gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled)"
        [ "$x" = "true" ] && x=false || x=true
        echo "Nightlight: $x"
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled $x
      '')
    ] ++ (with pkgs.gnomeExtensions; [
      appindicator
      dash-to-panel
      drop-down-terminal
      sound-output-device-chooser
    ]);
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;
    desktopManager.gnome3.enable = true;
    displayManager.sessionCommands = ''
      gsettings set org.gnome.desktop.interface enable-hot-corners false
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
      gsettings set org.gnome.desktop.interface icon-theme 'Numix'
      gsettings set org.gnome.desktop.interface show-battery-percentage true
      gsettings set org.gnome.desktop.media-handling automount false
      gsettings set org.gnome.desktop.media-handling autorun-never true
      gsettings set org.gnome.desktop.notifications show-in-lock-screen false
      gsettings set org.gnome.desktop.peripherals.mouse speed 0.375
      gsettings set org.gnome.desktop.privacy recent-files-max-age 30
      gsettings set org.gnome.desktop.privacy remove-old-temp-files true
      gsettings set org.gnome.desktop.privacy remove-old-trash-files true
      gsettings set org.gnome.desktop.privacy report-technical-problems false
      gsettings set org.gnome.desktop.privacy send-software-usage-stats false
      gsettings set org.gnome.desktop.screensaver lock-enabled false
      gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
      gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super>f']"
      gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
      gsettings set org.gnome.settings-daemon.plugins.media-keys logout '[]'
      gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
      gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

      echo 'window.ssd headerbar.titlebar { padding-top: 2px; padding-bottom: 2px; }' > ~/.config/gtk-3.0/gtk.css
    '';
  };
}
