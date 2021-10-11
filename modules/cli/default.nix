{ config, pkgs, lib, ... }:
let

  system-rev = toString config.system.nixos.revision;

in
{
  imports = [ ./powerline.nix ];

  sconfig.powerline.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    darkhttpd
    dnsutils
    du-dust
    entr
    file
    gcc
    git
    htop
    inetutils
    jq
    lm_sensors
    ncdu
    nix-index
    nix-top
    nixpkgs-fmt
    openssl
    psmisc
    pv
    pwgen
    python3
    rsync
    sqlite
    tcpdump
    tree
    unzip
    usbutils
    wget
    whois
    zip

    (writeShellScriptBin "dirt" "while sleep 1; do grep '^Dirty:' /proc/meminfo ; done")

    (writeShellScriptBin "nix-roots" "nix-store --gc --print-roots | grep -v ^/proc/")

    (writeShellScriptBin "pip-install" "exec python -m ensurepip --user")

    (writeShellScriptBin "nixos-check-reboot" ''
      set -e
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
      if [ "$booted" = "$built" ]
      then
          echo OK
          exit 0
      else
          echo REBOOT NEEDED
          exit 1
      fi
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
      echo "${system-rev} current local"
      echo "$(curl --silent -L ${config.system.defaultChannel}/git-revision) latest available"
      echo
    '')

  ];

  environment.etc.nixpkgs.source = pkgs.path;
  nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];

  environment.etc."pip.conf".text = ''
    [install]
    no-warn-script-location = false
  '';

  environment.variables.PLGO_HOSTNAMEFG = "0";
  environment.variables.PLGO_HOSTNAMEBG = "114";

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias catc='${pkgs.vimpager-latest}/bin/vimpager --force-passthrough'
    alias nix-env="echo nix-env is disabled #"
  '';

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.sconfig.start = with pkgs.vimPlugins; [
        vim-gitgutter
        vim-nix
      ];
      customRC = ''
        set encoding=utf-8
        scriptencoding utf-8
        set list nowrap scrolloff=9 updatetime=300 number
        highlight GitGutterAdd    ctermfg=10
        highlight GitGutterChange ctermfg=11
        highlight GitGutterDelete ctermfg=9
        let g:gitgutter_sign_removed = '◣'
        let g:gitgutter_sign_removed_first_line = '◤'
        let g:gitgutter_sign_modified_removed = '~~'
      '';
    };
  };
}
