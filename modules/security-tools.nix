{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.security-tools;
in
{
  options.sconfig.security-tools = lib.mkEnableOption "Enable security tools";

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      exiftool
      burpsuite
      nmap
      masscan
      binutils
      remmina
      openvpn
      socat
      ghidra-bin
      wfuzz
      gobuster
      dirb
      pwndbg
      thc-hydra
      metasploit
      bridge-utils
      macchanger
      iptables-nftables-compat
      dhcpdump

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
