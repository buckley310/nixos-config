{ config, lib, pkgs, ... }:
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
      feroxbuster
      ffuf
      gef
      ghidra-bin
      gobuster
      iptables-nftables-compat
      macchanger
      masscan
      metasploit
      msfpc
      net-snmp
      nmap
      openvpn
      postman
      pwndbg
      remmina
      security-wordlists
      socat
      thc-hydra
      webshells
      weevely
      wfuzz
    ];

    programs = {
      wireshark.enable = true;
      wireshark.package = pkgs.wireshark;
    };

    users.users.zim = {
      uid = 2099;
      isNormalUser = true;
    };
  };
}
