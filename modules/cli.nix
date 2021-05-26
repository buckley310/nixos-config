{ config, pkgs, lib, ... }:
let
  powerlineOpts = [
    "-mode=flat"
    "-colorize-hostname"
    "-cwd-mode=dironly"
    "-modules=user,host,cwd,nix-shell,git,jobs"
    "-git-assume-unchanged-size 0"
  ];

in
{
  environment.systemPackages = with pkgs; [
    pwgen
    pv
    tree
    psmisc
    ncdu
    git
    file
    sqlite
    usbutils
    entr
    gcc
    python3
    openssl
    wget
    lm_sensors
    htop
    jq
    zip
    unzip
    dnsutils
    whois
    tcpdump
    rsync
    nixpkgs-fmt
    nix-index

    (writeShellScriptBin "dirt" "while sleep 1; do grep '^Dirty:' /proc/meminfo ; done")

    (writeShellScriptBin "nix-roots" "nix-store --gc --print-roots | grep -v ^/proc/")

    (writeShellScriptBin "ns" ''
      exec nix shell "github:NixOS/nixpkgs/${toString config.system.nixos.revision}#$@"
    '')

    (writeShellScriptBin "pip_install" ''
      exec nix shell 'nixpkgs/nixos-unstable#python3.pkgs.pip' --command pip install --user -UI pip setuptools
    '')

    (writeScriptBin "zfsram" ''
      #!${pkgs.python3}/bin/python
      for ln in open('/proc/spl/kstat/zfs/arcstats').readlines():
          if ln.startswith('size '):
              print(str(int(ln.split(' ')[-1])/(1024*1024*1024))[:5],'GB')
    '')

    (writeShellScriptBin "channel" ''
      echo
      echo "NixOS ${config.system.nixos.release} (${config.system.defaultChannel})"
      echo
      echo "${toString config.system.nixos.revision} current local"
      echo "$(curl --silent -L ${config.system.defaultChannel}/git-revision) latest available"
      echo
    '')
  ];

  environment.etc."pip.conf".text = ''
    [install]
    no-warn-script-location = false
  '';

  environment.variables.EDITOR = "vim";

  environment.variables.PLGO_HOSTNAMEFG = "0";
  environment.variables.PLGO_HOSTNAMEBG = "114";

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias tmp='cd "$(TMPDIR=$XDG_RUNTIME_DIR mktemp -d)"'
    alias catc='${pkgs.vimpager-latest}/bin/vimpager --force-passthrough'
    alias nix-env="echo nix-env is disabled #"

    function _update_ps1() {
        PS1="\n$(${pkgs.powerline-go}/bin/powerline-go ${lib.concatStringsSep " " powerlineOpts})$ "
    }
    [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
