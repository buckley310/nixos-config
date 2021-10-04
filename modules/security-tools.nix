{ config, pkgs, lib, ... }:
let

  cfg = config.sconfig.security-tools;

in
{
  options.sconfig.security-tools = lib.mkEnableOption "Enable security tools";

  config = lib.mkIf cfg {
    environment.systemPackages = [ pkgs.security-toolbox ];

    programs = {
      wireshark.enable = true;
      wireshark.package = pkgs.wireshark;
    };

    users.users.sandy = {
      isSystemUser = true;
      useDefaultShell = true;
      home = "/home/sandy";
      createHome = true;
    };
  };
}
