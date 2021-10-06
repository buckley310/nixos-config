{ pkgs }:
let

  proxybrowser = pkgs.writeShellScriptBin "proxybrowser" ''
    exec ${pkgs.ungoogled-chromium}/bin/chromium \
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
pkgs.symlinkJoin {
  name = "security-toolbox";
  paths = with pkgs;
    [
      binutils
      bridge-utils
      dhcpdump
      dirb
      exiftool
      exploitdb
      gef
      ghidra-bin
      gobuster
      iptables-nftables-compat
      macchanger
      masscan
      metasploit
      net-snmp
      nmap
      openvpn
      proxybrowser
      remmina
      socat
      thc-hydra
      webshells
      weevely
      wfuzz

      (burpsuite.overrideAttrs (_: { meta = { }; }))
      (postman.overrideAttrs (_: { meta = { }; }))
    ];
}
