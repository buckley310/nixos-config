{ pkgs, lib, ... }:
let
  powerlineOpts = [
    "-mode=flat"
    "-colorize-hostname"
    "-cwd-mode=dironly"
    "-modules=user,host,cwd,nix-shell,git,jobs"
    "-git-assume-unchanged-size 0"
  ];

  rebuild-scripts = (map
    (x: (pkgs.writeShellScriptBin "sc-${builtins.head x}" "nixos-rebuild ${lib.concatStringsSep " " (builtins.tail x)}"))
    [
      [ "switch" "switch" ]
      [ "build" "build" ]
      [ "boot" "boot" ]
      [ "switch-upgrade" "switch" "--recreate-lock-file" "--refresh" ]
      [ "build-upgrade" "build" "--recreate-lock-file" "--refresh" ]
      [ "boot-upgrade" "boot" "--recreate-lock-file" "--refresh" ]
    ]
  );

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
      branch="$(jq -r .nodes.nixpkgs.original.ref </etc/nixos/flake.lock)"
      echo
      echo "$branch"
      echo
      echo "$(jq -r .nodes.nixpkgs.locked.rev </etc/nixos/flake.lock) current local"
      echo "$(git ls-remote https://github.com/NixOS/nixpkgs.git "$branch" | cut -f1) latest available"
      echo
    '')
  ] ++ rebuild-scripts;

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
