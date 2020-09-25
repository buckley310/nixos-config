{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "powerline-go";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "justjanne";
    repo = pname;
    rev = "d520fde89ba2d3d13d27e345e99aa23c958ac2dd";
    sha256 = "0g0rnx7czhfs9vw9qmrzf7qz9g8f8agslv6k353dl8l83c1inisr";
  };

  vendorSha256 = "0dkgp9vlb76la0j439w0rb548qg5v8648zryk3rqgfhd4qywlk11";

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A Powerline like prompt for Bash, ZSH and Fish";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sifmelcara ];
  };
}
