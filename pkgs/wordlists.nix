{ lib
, fetchFromGitHub
, fetchFromGitLab
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

  rockyou = runCommand
    "rockyou.txt"
    {
      src = fetchFromGitLab {
        group = "kalilinux";
        owner = "packages";
        repo = "wordlists";
        rev = "upstream/0.3";
        sha256 = "1slsz9mzcbvfvx928drvf9ayq3q5wbfqgm0p1khxc7m9yf20ilm2";
      };
    }
    "gunzip <$src/rockyou.txt.gz >$out";

  dirbuster = runCommand
    "dirbuster"
    {
      src = fetchFromGitLab {
        group = "kalilinux";
        owner = "packages";
        repo = "dirbuster";
        rev = "upstream/1.0";
        sha256 = "1500imrwhwr1zl59z1hq2bqhn05xjjl9lf3vp7dyx7dfx517i43y";
      };
    }
    "mkdir -p $out; cp -v $src/*.txt $out/";

in
runCommand "wordlists" { } ''
  mkdir -p $out/share/wordlists
  ln -s ${wfuzz.src}/wordlist $out/share/wordlists/wfuzz
  ln -s ${nmap-data} $out/share/wordlists/nmap
  ln -s ${seclists} $out/share/wordlists/seclists
  ln -s ${rockyou} $out/share/wordlists/rockyou.txt
  ln -s ${dirbuster} $out/share/wordlists/dirbuster
''
