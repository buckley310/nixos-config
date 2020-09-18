{ stdenv, fetchFromGitHub, glib, gettext }:

stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-bottompanel";
    version = "1901";

    src = fetchFromGitHub {
        owner = "Thoma5";
        repo = "gnome-shell-extension-bottompanel";
        rev = "3d9573896b122e9ccb02262249ca986f8dad1ebd";
        sha256 = "0lp25na5plz8vp8zjsikcadgy5hyx59ys2sbd4haagcalyv7jj4q";
    };

    phases = [ "installPhase" ];

    installPhase = ''
        mkdir -p "$out/share/gnome-shell/extensions"
        cp -r "$src" "$out/share/gnome-shell/extensions/bottompanel@tmoer93"

        chmod +w "$out/share/gnome-shell/extensions/bottompanel@tmoer93"
        sed -i 's/.*_rightPanelBarrier.*/if(Main.layoutManager._rightPanelBarrier)&/' "$out/share/gnome-shell/extensions/bottompanel@tmoer93/extension.js"
    '';

    meta = with stdenv.lib; {
        description = "Move your GNOME 3 shell panel to the bottom";
        homepage = https://github.com/Thoma5/gnome-shell-extension-bottompanel;
    };
}
