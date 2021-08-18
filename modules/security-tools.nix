{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.security-tools;
in
{
  options.sconfig.security-tools = lib.mkEnableOption "Enable security tools";

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      binutils
      bridge-utils
      burpsuite
      dhcpdump
      dirb
      exiftool
      gef
      ghidra-bin
      gobuster
      iptables-nftables-compat
      macchanger
      masscan
      metasploit
      nmap
      openvpn
      postman
      remmina
      socat
      thc-hydra
      wfuzz

      unstable.exploitdb
    ];

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
