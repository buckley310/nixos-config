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
    url = "https://apps.modpacks.ch/FTBApp/release/202212152008-a5a6712906-release/FTBA_unix_202212152008-a5a6712906-release.sh";
    sha256 = "da1aeba0c56c599b6b69d6cda60c2c327a3caa3fc8654306d78821459e2128dc";
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
