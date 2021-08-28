{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.sway;
in
{
  options.sconfig.sway = lib.mkEnableOption "Enable Sway Window Manager";

  config = lib.mkIf cfg {
    programs.sway = {
      enable = true;
      extraSessionCommands = ''
        export GTK_THEME="Yaru-dark";
        export MOZ_ENABLE_WAYLAND="1";
      '';
    };

    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Yaru-dark
      gtk-icon-theme-name=Numix
    '';

    environment.etc."sway/config".source = pkgs.runCommand "sway_config" { } ''
      (
        cat '${pkgs.sway}/etc/sway/config'
        cat <<"  EOF"
          include /etc/sway/config.d/*
        EOF
      )|
      sed 's/position top//' |
      sed 's/status_command while.*/status_command i3status/' |
      tee "$out"
    '';

    services.gvfs.enable = true;
    programs.dconf.enable = true;
    networking.networkmanager.enable = true;

    services.xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.gdm.enable = true;
    };

    environment.systemPackages = with pkgs; [
      numix-icon-theme
      yaru-theme
      gnome3.networkmanagerapplet
      gnome3.file-roller
      gnome3.adwaita-icon-theme
      mate.mate-terminal
      xfce.thunar
      i3status
      xfce.thunar-archive-plugin
      caffeine-ng
      wf-recorder
      xdg_utils
    ];
  };
}
