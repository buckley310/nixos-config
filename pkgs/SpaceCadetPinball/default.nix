{ lib
, stdenv
, fetchFromGitHub
, cmake
, SDL2
, SDL2_mixer
, p7zip
, requireFile
}:
let

  extractCab = file:
    let
      cab = lib.substring 0 ((lib.stringLength file) - 1) file;
    in
    ''
      ${p7zip}/bin/7z x I386/${cab}_
      cp ${lib.toLower file} $out/${file}
    '';

  spacecadet_files = stdenv.mkDerivation {
    name = "spacecadet_files";
    src = requireFile rec {
      name = "en_windows_xp_professional_with_service_pack_3_x86_cd_x14-80428.iso";
      sha256 = "62b6c91563bad6cd12a352aa018627c314cfc5162d8e9f8af0756a642e602a46";
      message = ''
        Windows iso required for SpaceCadetPinball.
        nix-store --add-fixed sha256 ${name}
      '';
    };
    dontBuild = true;
    unpackPhase = "${p7zip}/bin/7z x $src";
    installPhase = ''
      mkdir -p $out
    '' + (lib.concatMapStrings extractCab (import ./cab_list.nix));
  };

in
stdenv.mkDerivation rec {
  pname = "SpaceCadetPinball";
  version = "2021-10-25";

  src = fetchFromGitHub {
    owner = "k4zmu2a";
    repo = pname;
    sha256 = "DJM+bh+JqCqCp4ub9CpuOiAeQ+DKiKVFUTcY09XEOZA=";
    rev = "3ec96b84add67921a2a2ca552b0bbd400d14d70a";
  };

  nativeBuildInputs = [ cmake SDL2 SDL2_mixer ];

  installPhase = ''
    mkdir -p $out/share/${pname} $out/bin
    mv ../bin/SpaceCadetPinball $out/share/${pname}/
    cp ${spacecadet_files}/* $out/share/${pname}/
    ln -s $out/share/${pname}/SpaceCadetPinball $out/bin/SpaceCadetPinball
  '';
}
