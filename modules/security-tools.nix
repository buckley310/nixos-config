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

    (writeShellScriptBin "searchsploit" ''
      set -e
      (
          cd ~/.cache
          [ -e exploitdb ] || git clone https://github.com/offensive-security/exploitdb.git
          cd exploitdb
          if find .git -maxdepth 0 -cmin +60 | grep -q git
          then
              git pull
          fi
      )
      exec ~/.cache/exploitdb/searchsploit "$@"
    '')
  ];

  programs = {
    wireshark.enable = true;
    wireshark.package = pkgs.wireshark;
  };
}
