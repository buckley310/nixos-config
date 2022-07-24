{ stdenv
, alsaLib
, autoPatchelfHook
, dbus
, fontconfig
, freetype
, glib
, krb5
, libglvnd
, libICE
, libSM
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXi
, libxkbcommon
, libXrandr
, libXrender
, libXtst
, makeWrapper
, ncurses
, nss
, python3
, requireFile
, systemd
, unzip
, xcbutilimage
, xcbutilkeysyms
, xcbutilrenderutil
, xcbutilwm
, xkeyboardconfig
, zlib
}:

let
  hjs = builtins.fromJSON (builtins.readFile ./hashes.js);

in
stdenv.mkDerivation rec {
  pname = "binaryninja";
  inherit (hjs) version;

  autoPatchelfIgnoreMissingDeps = [
    "libQt6PrintSupport.so.6"
    "libQt6Qml.so.6"
  ];

  src = requireFile rec {
    name = "BinaryNinja-personal.zip";
    url = "https://binary.ninja";
    sha256 = hjs.hashes.${name};
  };

  buildInputs = [
    alsaLib
    autoPatchelfHook
    dbus
    fontconfig
    freetype
    glib
    krb5
    libglvnd
    libICE
    libSM
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXi
    libxkbcommon
    libXrandr
    libXrender
    libXtst
    makeWrapper
    ncurses
    nss
    python3
    stdenv.cc.cc.lib
    unzip
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    zlib
  ];

  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/lib $out/bin $out/share
    mv $NIX_BUILD_TOP/$sourceRoot $out/lib/binary-ninja
    makeWrapper $out/lib/binary-ninja/binaryninja $out/bin/binaryninja \
        --suffix LD_LIBRARY_PATH : "${systemd}/lib" \
        --suffix LD_LIBRARY_PATH : "${python3}/lib" \
        --set QT_XKB_CONFIG_ROOT "${xkeyboardconfig}/share/X11/xkb" \
        --set QTCOMPOSE "${libX11.out}/share/X11/locale"
  '';

  meta.platforms = [ "x86_64-linux" ];
}
