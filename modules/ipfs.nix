{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.ipfs;
in
{
  options.sconfig.ipfs = {

    enable = lib.mkEnableOption "Turn on IPFS";

    lowpower = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the 'lowpower' profile in IPFS.";
    };

  };

  config = lib.mkIf cfg.enable {

    services.ipfs = {
      enable = true;
      emptyRepo = true;
      gatewayAddress = "/ip4/127.0.0.1/tcp/8001";
      # Had issues without fdlimit. 65536 value taken from nixpkgs example
      serviceFdlimit = 65536;
    };

    systemd.services.ipfs = {
      preStart = lib.mkAfter (lib.optionalString cfg.lowpower ''
        ipfs --offline config profile apply lowpower
      '');
      postStart = ''
        chmod g+r /var/lib/ipfs/config
      '';
    };

  };
}
