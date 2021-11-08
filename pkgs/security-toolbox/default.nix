{ symlinkJoin
, writeShellScriptBin
, chromium
, binutils
, bridge-utils
, dhcpdump
, dirb
, exiftool
, gef
, ghidra-bin
, gobuster
, iptables-nftables-compat
, macchanger
, masscan
, metasploit
, msfpc
, net-snmp
, nmap
, openvpn
, remmina
, socat
, thc-hydra
, webshells
, weevely
, wfuzz
, burpsuite
, postman
}:

let

  proxybrowser = writeShellScriptBin "proxybrowser" ''
    exec ${chromium}/bin/chromium \
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
symlinkJoin {
  name = "security-toolbox";
  paths =
    [
      proxybrowser

      binutils
      bridge-utils
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
      msfpc
      net-snmp
      nmap
      openvpn
      remmina
      socat
      thc-hydra
      webshells
      weevely
      wfuzz

      (burpsuite.overrideAttrs (_: { meta = { }; }))
      (postman.overrideAttrs (_: { meta = { }; }))
    ];

  meta.platforms = [ "x86_64-linux" ];
}
