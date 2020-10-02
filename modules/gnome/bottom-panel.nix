{ stdenv, fetchFromGitHub, glib, gettext }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-bottompanel";
  version = "1901";

  src = fetchFromGitHub {
    owner = "Thoma5";
    repo = "gnome-shell-extension-bottompanel";
    rev = "72d07b98276d48bd580ea731a0f49f46018d556d";
    sha256 = "1hpp39cpfd5h7x3j1b3nfly7c98sj10xqnwcmsr3d4jxkwh2vsbl";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/share/gnome-shell/extensions"
    cp -r "$src" "$out/share/gnome-shell/extensions/bottompanel@tmoer93"
  '';

  meta = with stdenv.lib; {
    description = "Move your GNOME 3 shell panel to the bottom";
    homepage = https://github.com/Thoma5/gnome-shell-extension-bottompanel;
  };
}
