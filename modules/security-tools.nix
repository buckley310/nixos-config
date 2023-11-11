{ config, lib, pkgs, ... }:
let

  cfg = config.sconfig.security-tools;

in
{
  options.sconfig.security-tools = lib.mkEnableOption "Enable security tools";

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [
      binutils
      burpsuite
      exiftool
      feroxbuster
      ghidra-bin
      masscan
      metasploit
      msfpc
      nmap
      openvpn
      remmina
      seclists
      socat
      thc-hydra
      webshells
      weevely
      wfuzz

      (runCommand "gdb" { } "install -D ${gef}/bin/gef $out/bin/gdb")
    ];

    programs.bash.interactiveShellInit = ''
      alias feroxbuster="feroxbuster --no-state"
    '';

    system.activationScripts.seclists = ''
      mkdir -m 0755 -p /usr/share
      ln -sf /run/current-system/sw/share/seclists /usr/share/
    '';

    networking.firewall.allowedTCPPorts = [
      8000
      9999
    ];

    programs = {
      wireshark.enable = true;
      wireshark.package = pkgs.wireshark;
    };
  };
}
