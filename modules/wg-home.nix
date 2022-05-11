{ config, lib, pkgs, ... }:
{
  options.sconfig.wg-home.enable = lib.mkEnableOption "set up home VPN";

  config = lib.mkIf config.sconfig.wg-home.enable {
    systemd.services.wg-home = {
      script = "wg-quick up /nix/persist/wireguard_home.conf";
      preStop = "wg-quick down /nix/persist/wireguard_home.conf";
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
