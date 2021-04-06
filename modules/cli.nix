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
    ffmpeg
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

    (vim_configurable.customize {
      name = "vim";
      vimrcConfig.customRC = ''
        syntax enable
        filetype plugin indent on
        set nowrap ruler scrolloff=9 backspace=start,indent
      '';
    })

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
      echo "${config.system.nixos.revision} current local"
      echo "$(curl --silent -L ${config.system.defaultChannel}/git-revision) latest available"
      echo
    '')
  ];

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
    alias tmp='cd $(mktemp -d)'
    alias buildsys='nix build -f "<nixpkgs/nixos>" --no-link system'
    alias sha256sum-base32='nix hash-file --type sha256 --base32'
    alias pip_install='nix run nixpkgs.python3.pkgs.pip -c pip install --user -UI pip setuptools'
    alias catc='${pkgs.vimpager-latest}/bin/vimpager --force-passthrough'

    function _update_ps1() {
        PS1="\n$(${pkgs.powerline-go}/bin/powerline-go ${lib.concatStringsSep " " powerlineOpts})$ "
    }
    [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
