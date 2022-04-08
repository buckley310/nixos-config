{ lib
, curl
, fetchFromGitHub
, nmap
, runCommand
, wfuzz
}:
let

  nmap-data = runCommand "nmap-data" { } ''
    tar --strip-components=1 -xvf ${nmap.src}
    mv nselib/data $out
  '';

  seclists = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "SecLists";
    rev = "cb81804316c634728bbddb857ce7dfa5016e01b1";
    sha256 = "QBlZlS8JJI6pIdIaD1I+7gMuPPfEybxybj2HrnQM7co=";
  };

  rockyou = runCommand "rockyou.txt"
    {
      outputHashAlgo = "sha256";
      outputHash = "0wv1d2b00x294irnqki9vvbicmysdsa1vphkqmhhbjs2fzm5y0qn";
    }
    ''
      url="https://gitlab.com/kalilinux/packages/wordlists/-/raw/upstream/0.3/rockyou.txt.gz"
      ${curl}/bin/curl --insecure "$url" | gunzip >$out
    '';

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
  ln -s ${nmap-data} $out/share/wordlists/nmap
  ln -s ${seclists} $out/share/wordlists/seclists
  ln -s ${rockyou} $out/share/wordlists/rockyou.txt
  ln -s ${dirbuster} $out/share/wordlists/dirbuster
''
