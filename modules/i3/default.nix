{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.i3;
in
{
  options.sconfig.i3 = {
    enable = lib.mkEnableOption "Enable the i3 Window Manager";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.windowManager.i3 = {
      enable = true;
      extraSessionCommands = ''
        mkdir -p ~/.local/share/icons/default
        ln -sf /run/current-system/sw/share/icons/Yaru/cursor.theme ~/.local/share/icons/default/index.theme
        echo 'Xft.dpi: 96' > ~/.Xresources
        echo 'Xcursor.size: 24' >> ~/.Xresources
        xsetroot -solid '#333333'
      '';
    };

    hardware.pulseaudio.enable = true;

    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Yaru-dark
      gtk-icon-theme-name=Numix
    '';

    environment.etc."i3/config".source = pkgs.runCommand "i3config" { } ''
      (
        cat '${pkgs.i3}/etc/i3/config' |
        sed 's/Mod1/Mod4/' |
        sed 's/exec i3-config-wizard//' |
        sed 's/^font/#font/' |
        sed 's,status_command i3status,status_command i3status -c ${./i3status.conf},' |
        sed 's/i3-sensible-terminal/alacritty/' |
        sed 's/10%/2%/'
        cat '${pkgs.writeText "i3extra" cfg.extraConfig}'
        echo 'bindsym XF86MonBrightnessUp exec brightnessctl   -n500 -e s -- +10%'
        echo 'bindsym XF86MonBrightnessDown exec brightnessctl -n500 -e s -- -10%'
      )|
      tee "$out"
    '';

    services.gvfs.enable = true;
    networking.networkmanager.enable = true;

    services.xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.sddm.enable = true;
    };

    environment.systemPackages = with pkgs; [
      alacritty
      brightnessctl
      numix-icon-theme
      yaru-theme
      gnome3.networkmanagerapplet
      gnome3.file-roller
      gnome3.adwaita-icon-theme
      mate.mate-terminal
      xfce.thunar
      xfce.thunar-archive-plugin
      caffeine-ng
    ];
  };
}
