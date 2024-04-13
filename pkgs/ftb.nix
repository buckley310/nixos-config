{ lib
, dpkg
, fetchurl
, stdenv
, steam-run
}:

stdenv.mkDerivation rec {
  pname = "ftb";
  version = "1.25.7";

  src = fetchurl {
    url = "https://piston.feed-the-beast.com/app/ftb-app-${version}-amd64.deb";
    sha256 = "22714531d506503dad34b10daf5b5757351b5451fd03deecf24af7ad05fd55c2";
  };

  nativeBuildInputs = [ dpkg ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv opt $out/

    cat <<EOF >$out/bin/ftb
    #!/usr/bin/env bash
    exec ${steam-run}/bin/steam-run '$out/opt/FTB App/ftb-app'
    EOF

    chmod +x $out/bin/ftb
  '';

  meta = {
    homepage = "https://feed-the-beast.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
