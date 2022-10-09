{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.wg-home;
in
{
  options.sconfig.wg-home = {

    enable = lib.mkEnableOption "set up home VPN";

    path = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos/wireguard_home.conf";
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.wg-home = {
      script = "wg-quick up ${cfg.path}";
      preStop = "wg-quick down ${cfg.path}";
      path = [ pkgs.wireguard-tools ];
      serviceConfig = {
        type = "oneshot";
        RemainAfterExit = true;
      };
    };
    boot.kernelModules = [ "wireguard" ];
    environment.systemPackages = [ pkgs.wireguard-tools ];
  };
}
