{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pwgen
    pv
    tree
    tmux
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
    hugo
    openssl
    wget
    lm_sensors
    htop
    jq
    zip
    unzip
    dnsutils
    tcpdump
    rsync
    nixpkgs-fmt

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
      nixos="/nix/var/nix/profiles/per-user/root/channels/nixos"
      [[ "$(<$nixos/.version-suffix)" =~ ^pre ]] &&
          channel="unstable" ||
          channel="$(<$nixos/.version)"
      echo
      echo "nixos-$channel"
      echo
      echo "$(<$nixos/.git-revision) current local"
      echo "$(curl --silent -L "https://channels.nixos.org/nixos-$channel/git-revision") latest available"
      echo
    '')
  ];

  virtualisation.podman.enable = true;

  environment.variables.EDITOR = "vim";

  environment.variables.PLGO_HOSTNAMEFG = "0";
  environment.variables.PLGO_HOSTNAMEBG = "114";

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias tmp='cd $(mktemp -d)'
    alias buildsys='nix build -f "<nixpkgs/nixos>" --no-link system'

    function _update_ps1() {
        PS1="\n$(${pkgs.callPackage ../pkgs/powerline-go-updated { }}/bin/powerline-go \
                    -mode=flat \
                    -colorize-hostname \
                    -cwd-mode=dironly \
                    -modules=user,host,cwd,nix-shell,git,jobs \
                    -git-assume-unchanged-size 0 \
        )$ "
    }
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  '';
}
