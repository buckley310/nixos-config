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

    nixpkgs.overlays = [
      (self: super: {
        postman = super.postman.overrideAttrs (old: rec {
          buildInputs = old.buildInputs ++ [ pkgs.libxkbcommon ];
          version = "8.10.0";
          src = super.fetchurl {
            url = "https://dl.pstmn.io/download/version/${version}/linux64";
            sha256 = "05f3eaa229483a7e1f698e6e2ea2031d37687de540d4fad05ce677ac216db24d";
            name = "postman.tar.gz";
          };
          postFixup = ''
            pushd $out/share/postman
            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" _Postman
            for file in $(find . -type f \( -name \*.node -o -name _Postman -o -name \*.so\* \) ); do
              ORIGIN=$(patchelf --print-rpath $file); \
              patchelf --set-rpath "${lib.makeLibraryPath buildInputs}:$ORIGIN" $file
            done
            popd
          '';
        });
      })
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
