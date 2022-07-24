{ config, lib, pkgs, ... }:
let

  cfg = config.sconfig.security-tools;

  proxybrowser = pkgs.writeShellScriptBin "proxybrowser" ''
    exec ${pkgs.chromium}/bin/chromium \
    --disable-background-networking \
    --disable-default-apps \
    --disable-plugins-discovery \
    --disk-cache-size=0 \
    --ignore-certificate-errors \
    --no-default-browser-check \
    --no-experiments \
    --no-first-run \
    --no-pings \
    --no-service-autorun \
    --user-data-dir="$HOME/.proxybrowser" \
    --proxy-server="localhost:8080" \
    --proxy-bypass-list='<-loopback>'
  '';

in
{
  options.sconfig.security-tools = lib.mkEnableOption "Enable security tools";

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      proxybrowser

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
