{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    {
      specialisation.xorg.configuration = {
        sconfig.gnome = true;
        services.xserver.displayManager.gdm.wayland = false;
        services.xserver.screenSection = ''
          Option "metamodes" "DP-2: 2560x1440_165 +0+0 {AllowGSYNCCompatible=On}"
        '';
      };
    }
    (
      { lib, config, ... }:
      {
        config = lib.mkIf (config.specialisation != { }) {
          sconfig.hypr.enable = true;
        };
      }
    )
  ];
}
