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
      ghidra-bin
      gobuster
      iptables-nftables-compat
      macchanger
      masscan
      nmap
      openvpn
      pwndbg
      remmina
      socat
      thc-hydra
      wfuzz

      unstable.exploitdb
      unstable.metasploit
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
