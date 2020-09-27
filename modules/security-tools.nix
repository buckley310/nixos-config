{ config, pkgs, ... }:
{
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
  ];

  programs = {
    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;
  };
}
