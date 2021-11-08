{ stdenv
, fetchFromGitHub
, metasploit
}:

stdenv.mkDerivation rec {
  pname = "msfpc";
  version = "2021.01";

  src = fetchFromGitHub {
    owner = "g0tmi1k";
    repo = "msfpc";
    rev = "8007ef2142e43dc5e97edf84f40ac012f94a3e8f";
    sha256 = "/FNhQcjIEIzB+wRKF2e3eYEnuVrl0egBZvjZidCwvHg=";
  };

  installPhase = ''
    install -D ${src}/msfpc.sh $out/bin/msfpc
    sed 's|## msfvenom installed?|PATH="$PATH:${metasploit}/bin"|' -i $out/bin/msfpc
  '';
}
