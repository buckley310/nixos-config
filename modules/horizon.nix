{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.horizon;
in
{
  options.sconfig.horizon.enable = lib.mkEnableOption "Enable vmware-horizon";

  config = lib.mkIf cfg.enable
    {
      systemd.services.vmware-usbarbitrator = {
        serviceConfig.Type = "forking";
        wantedBy = [ "multi-user.target" ];
        script = "${pkgs.vmware-horizon-client}/bin/vmware-usbarbitrator";
        preStart = ''
          vdir="/var/run/vmware/$(id -u sean)"
          mkdir -p $vdir
          chmod 700 $vdir
          chown sean $vdir
        '';
      };
      environment.systemPackages = [ pkgs.vmware-horizon-client ];
    };
}
