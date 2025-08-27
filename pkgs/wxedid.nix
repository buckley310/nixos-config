{
  bash,
  fetchurl,
  gtk3,
  makeWrapper,
  stdenv,
  wxGTK32,
}:
stdenv.mkDerivation rec {
  pname = "wxedid";
  version = "0.0.32";
  buildInputs = [ wxGTK32 ];
  nativeBuildInputs = [ makeWrapper ];
  prePatch = ''
    sed -i "s,/bin/bash,${bash}/bin/bash," "./src/rcode/rcd_autogen"
  '';
  src = fetchurl {
    url = "https://downloads.sourceforge.net/${pname}/${pname}-${version}.tar.gz";
    sha256 = "5d86d136e43e85ad3980982cecff87cf175192c151247c4b8960df9c5e461cc2";
  };
  postInstall = ''
    mv $out/bin/wxedid $out/bin/.wxedid-wrapped
    makeWrapper $out/bin/.wxedid-wrapped $out/bin/wxedid \
      --suffix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  '';
}
