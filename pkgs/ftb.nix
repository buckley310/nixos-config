# https://feed-the-beast.com/

{ stdenv
, autoPatchelfHook
, fetchurl
, jre
, bash
, makeWrapper
, writeShellScriptBin
, buildFHSUserEnv
}:

let
  installer = fetchurl {
    url = "https://apps.modpacks.ch/FTBApp/release/202211151621-329441ed6d-release/FTBA_unix_202211151621-329441ed6d-release.sh";
    sha256 = "f6a25f9fd4f5c33a48620f311fcac541ddd2e2c014f1487dc2e5c1a8493007d0";
  };

  fhs = buildFHSUserEnv {
    name = "fhs";
    runScript = "~/FTBA/FTBApp";

    targetPkgs = pkgs: with pkgs; [
      at-spi2-atk
      atk
      cairo
      nspr
      dbus
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk2
      libdrm
      cups
      gtk3-x11
      harfbuzz
      liberation_ttf
      libjpeg
      libpulseaudio
      libtiff
      libudev0-shim
      expat
      nss
      libuuid
      libv4l
      libxml2
      pango
      pcsclite
      at-spi2-core
      pixman
      alsa-lib
      libglvnd
      libxkbcommon
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libxcb
      xorg.libXi
      xorg.libXinerama
      xorg.libxkbfile
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXtst
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXxf86vm
      mesa_drivers
      zlib
    ];

  };

in
writeShellScriptBin "ftb" ''
  export PATH="$PATH:${jre}/bin"
  [ -d ~/FTBA ] || bash ${installer} -q
  ${fhs}/bin/fhs
''
