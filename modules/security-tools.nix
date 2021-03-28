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

      (callPackage ../pkgs/binary-ninja-personal { })

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

    users.users.sandy = {
      isNormalUser = true;
      isSystemUser = true;
    };
  };
}
