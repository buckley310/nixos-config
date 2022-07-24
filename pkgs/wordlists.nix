{ lib
, curl
, fetchFromGitHub
, nmap
, runCommand
, wfuzz
}:
let

  seclists = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "SecLists";
    rev = "2022.2";
    sha256 = "Xi4FsrVYioR5HBVJzo0bug5ETgV2mCtulPOpBXm+Y1s=";
  };

  dirbuster = runCommand "dirbuster"
    {
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      outputHash = "0l2sgagdxahqi7zqqw9v9v9g2gmqbdl2cyz0rvlmc4di6crdn36s";
    }
    ''
      url="https://gitlab.com/kalilinux/packages/dirbuster/-/archive/upstream/1.0/dirbuster-upstream-1.0.tar.gz"
      mkdir $out
      ${curl}/bin/curl --insecure "$url" |
        tar -C$out -xvz --strip-components=1 --wildcards '*.txt'
    '';

in
runCommand "wordlists" { } ''
  mkdir -p $out/share/wordlists
  ln -s ${wfuzz.src}/wordlist $out/share/wordlists/wfuzz
  ln -s ${nmap}/share/nmap/nselib/data $out/share/wordlists/nmap
  ln -s ${seclists} $out/share/wordlists/seclists
  ln -s ${dirbuster} $out/share/wordlists/dirbuster
''
