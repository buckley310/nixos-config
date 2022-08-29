{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.xmonad;
in
{
  options.sconfig.xmonad.enable = lib.mkEnableOption "xmonad";

  # extraSessionCommands = ''
  #   echo 'Xft.dpi: 96' | xrdb -merge
  #   echo 'Xcursor.size: 24' | xrdb -merge
  #   xsetroot -solid '#333333'
  # '';

  config = lib.mkIf cfg.enable {
    services.xserver.windowManager.xmonad = {
      enable = true;
      extraPackages = haskellPackages: [
        haskellPackages.dbus
        haskellPackages.List
        haskellPackages.monad-logger
        haskellPackages.xmobar
        haskellPackages.xmonad
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
      ];
    };

    hardware.pulseaudio.enable = true;

    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita-dark
    '';

    services.gvfs.enable = true;
    networking.networkmanager.enable = true;

    services.xserver = {
      enable = true;
      libinput.enable = true;
      libinput.touchpad.naturalScrolling = true;
      displayManager.sddm.enable = true;
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
      dmenu
      gnome-themes-extra
      networkmanagerapplet
      gnome3.file-roller
      gnome3.adwaita-icon-theme
      mate.mate-terminal
      xfce.thunar
      xfce.thunar-archive-plugin
      caffeine-ng
      i3status-rust
      xmobar

      (haskellPackages.ghcWithPackages (p: [
        p.dbus
        p.List
        p.monad-logger
        p.xmobar
        p.xmonad
        p.xmonad-contrib
        p.xmonad-extras
      ]))

      (writeTextFile {
        name = "index.theme";
        destination = "/share/icons/default/index.theme";
        text = ''
          [Icon Theme]
          Name=Adwaita
          Inherits=Adwaita
        '';
      })

      (runCommand "x-terminal-emulator" { } ''
        mkdir -p $out/bin
        ln -s ${alacritty}/bin/alacritty $out/bin/x-terminal-emulator
      '')
    ];
  };
}
