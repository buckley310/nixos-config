{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.ipfs;
in
{
  options.sconfig.ipfs = {
    enable = lib.mkEnableOption "Turn on IPFS";
  };

  config = lib.mkIf cfg.enable {

    services.ipfs = {
      enable = true;
      emptyRepo = true;
      gatewayAddress = "/ip4/127.0.0.1/tcp/8001";
      # Had issues without fdlimit. 65536 value taken from nixpkgs example
      serviceFdlimit = 65536;
      extraConfig = {
        AutoNAT.ServiceMode = "disabled"; # maybe "enabled" for servers?
        Reprovider.Strategy = "pinned";
        Routing.Type = "dhtclient"; # maybe "dht" for servers?
        Swarm.ConnMgr.HighWater = 1000;
        Swarm.ConnMgr.LowWater = 50;
        Swarm.DisableNatPortMap = true; # Disable UPnP
      };
    };

    systemd.services.ipfs.postStart = ''
      chmod g+r /var/lib/ipfs/config
    '';

  };
}
