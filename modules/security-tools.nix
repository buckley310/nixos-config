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
      seclists
      socat
      thc-hydra
      webshells
      weevely
      wfuzz
    ];

    system.activationScripts.seclists = ''
      mkdir -m 0755 -p /usr/share
      ln -sf /run/current-system/sw/share/seclists /usr/share/
    '';

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
