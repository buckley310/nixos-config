{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.ipfs;

  modes = {
    server = {
      AutoNAT.ServiceMode = "disabled"; # maybe change this to "enabled" ?
      Reprovider.Strategy = "pinned";
      Routing.Type = "dhtclient"; # maybe change this to "dht" ?
      Swarm.ConnMgr.HighWater = 900;
      Swarm.ConnMgr.LowWater = 600;
      Swarm.DisableNatPortMap = true; # Disable UPnP
    };
    desktop = {
      AutoNAT.ServiceMode = "disabled";
      Reprovider.Strategy = "pinned";
      Routing.Type = "dhtclient";
      Swarm.ConnMgr.HighWater = 300;
      Swarm.ConnMgr.LowWater = 50;
      Swarm.DisableNatPortMap = true; # Disable UPnP
    };
  };

in
{
  options.sconfig.ipfs = {

    enable = lib.mkEnableOption "Turn on IPFS";
    mode = lib.mkOption { type = lib.types.enum [ "server" "desktop" ]; };

  };

  config = lib.mkIf cfg.enable {

    services.ipfs = {
      enable = true;
      emptyRepo = true;
      extraConfig = modes.${cfg.mode};
      gatewayAddress = "/ip4/127.0.0.1/tcp/8001";
      # Had issues without fdlimit. 65536 value taken from nixpkgs example
      serviceFdlimit = 65536;
    };

    systemd.services.ipfs.postStart = ''
      chmod g+r /var/lib/ipfs/config
    '';

  };
}
