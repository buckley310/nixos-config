{ lib
, stdenv
, fetchFromGitHub
, glib
, gettext
, sassc
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-dash-to-dock";
  version = "69";

  src = fetchFromGitHub {
    owner = "ewlsh";
    repo = "dash-to-dock";
    rev = "a2d40e2a06117617bcbc5f85608c895c7734604e";
    hash = "sha256-Kb4TlZAjXu7M/xL9maTZgJT19+PCopB5U9ZRXeaN/mM=";
  };

  nativeBuildInputs = [
    glib
    gettext
    sassc
  ];

  makeFlags = [
    "INSTALLBASE=${placeholder "out"}/share/gnome-shell/extensions"
  ];

  uuid = "dash-to-dock@micxgx.gmail.com";

  meta = with lib; {
    description = "A dock for the Gnome Shell";
    homepage = "https://micheleg.github.io/dash-to-dock/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ eperuffo jtojnar ];
  };
}
