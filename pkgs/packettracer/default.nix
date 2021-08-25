{ stdenv
, alsaLib
, autoPatchelfHook
, buildFHSUserEnvBubblewrap
, dbus
, dpkg
, expat
, fetchurl
, fontconfig
, glib
, libdrm
, libglvnd
, libpulseaudio
, libudev0-shim
, libxkbcommon
, libxml2
, libxslt
, makeDesktopItem
, makeWrapper
, nspr
, nss
, xlibs

, blockInternet ? true

}:

assert stdenv.hostPlatform.system == "x86_64-linux";

let
  version = "8.0.1";

  ptFiles = stdenv.mkDerivation {
    name = "PacketTracer";
    inherit version;

    src = fetchurl {
      # This file was uploaded by someone else, but I have verified the hash.
      url = "https://archive.org/download/cisco-packet-tracer-801/CiscoPacketTracer_801_Ubuntu_64bit.deb";
      sha256 = "77a25351b016faed7c78959819c16c7013caa89c6b1872cb888cd96edd259140";
    };

    nativeBuildInputs = [
      alsaLib
      autoPatchelfHook
      dbus
      dpkg
      expat
      fontconfig
      glib
      libdrm
      libglvnd
      libpulseaudio
      libudev0-shim
      libxkbcommon
      libxml2
      libxslt
      makeWrapper
      nspr
      nss
      xlibs.libICE
      xlibs.libSM
      xlibs.libX11
      xlibs.libxcb
      xlibs.libXcomposite
      xlibs.libXcursor
      xlibs.libXdamage
      xlibs.libXext
      xlibs.libXfixes
      xlibs.libXi
      xlibs.libXrandr
      xlibs.libXrender
      xlibs.libXScrnSaver
      xlibs.xcbutilimage
      xlibs.xcbutilkeysyms
      xlibs.xcbutilrenderutil
      xlibs.xcbutilwm
    ];

    dontUnpack = true;
    installPhase = ''
      dpkg-deb -x $src $out
      chmod 755 "$out"
      makeWrapper "$out/opt/pt/bin/PacketTracer" "$out/bin/packettracer" \
        --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"

      # Keep source archive cached, to avoid re-downloading
      ln -s "$src" "$out/usr/share/"
    '';
  };

  desktopItem = makeDesktopItem {
    name = "cisco-pt.desktop";
    desktopName = "Packet Tracer";
    icon = "${ptFiles}/opt/pt/art/app.png";
    exec = "packettracer %f";
    mimeType = "application/x-pkt;application/x-pka;application/x-pkz;";
  };

in
buildFHSUserEnvBubblewrap {
  name = "packettracer";
  unshareNet = blockInternet;
  runScript = "${ptFiles}/bin/packettracer";
  targetPkgs = pkgs: [ libudev0-shim ];

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp "${desktopItem}"/share/applications/* "$out/share/applications/"
  '';
}
