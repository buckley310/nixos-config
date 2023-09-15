{ config, lib, pkgs, ... }:
{
  imports = [
    ./kubernetes.nix
    ./powerline.nix
  ];

  environment.systemPackages = with pkgs; [
    dnsutils
    du-dust
    entr
    file
    gcc
    iftop
    inetutils
    iotop
    jq
    lm_sensors
    ncdu
    nix-index
    nix-prefetch-github
    nix-top
    nixpkgs-fmt
    nodejs
    openssl
    parted
    pciutils
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
    yq
    zip

    (writeShellScriptBin "dirt" "while sleep 1; do grep '^Dirty:' /proc/meminfo ; done")

    (writeShellScriptBin "nr" "exec nix repl \"$(nix eval nixpkgs#path)\"")

    (lib.hiPrio (writeShellScriptBin "iftop" ''
      exec ${iftop}/bin/iftop -P -m100M "$@"
    ''))

    (writeShellScriptBin "bat" ''
      ${bat}/bin/bat --color=always --wrap=never --terminal-width=80 "$@"
    '')

    (writeShellScriptBin "pip-install" ''
      nix run 'nixpkgs#python3.pkgs.pip' -- install --user --upgrade --break-system-packages pip
    '')

    (writeShellScriptBin "nix-roots" ''
      nix-store --gc --print-roots | grep -v \
        -e '^/proc/' \
        -e '/.cache/nix/flake-registry.json '
    '')

    (writeScriptBin "zfsram" ''
      #!${pkgs.python3}/bin/python
      for ln in open('/proc/spl/kstat/zfs/arcstats').readlines():
          if ln.startswith('size '):
              print(str(int(ln.split(' ')[-1])/(1024*1024*1024))[:5],'GB')
    '')

    (darkhttpd.overrideAttrs (old: {
      patches = [
        (builtins.toFile "port.patch" ''
          --- a/darkhttpd.c
          +++ b/darkhttpd.c
          @@ -291 +291 @@ static const char *bindaddr;
          -static uint16_t bindport = 8080;    /* or 80 if running as root */
          +static uint16_t bindport = 8000;    /* or 80 if running as root */
        '')
      ];
    }))

  ];

  environment.variables.HTOPRC = "/dev/null";
  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = 1;
      highlight_base_name = 1;
      show_program_path = 0;
      tree_sort_direction = -1;
      tree_view = 1;
      update_process_names = 1;
    };
  };

  programs.git = {
    enable = true;
    config = {
      alias.up = "push";
      alias.dn = "pull";
      alias.sh = "show";
      alias.glog = "log --all --decorate --oneline --graph";
      alias.logl = "log --oneline -n10";
      alias.vlog = "log --name-status";
      core.pager = "less -x1,5";
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    extraConfig = ''
      bind-key j command-prompt -p "Join pane:"  "join-pane -s '%%'"
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key '%' split-window -h -c "#{pane_current_path}"
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on
    '';
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias hd='hexdump -C'
    alias nix-env="echo nix-env is disabled #"
    alias nix-what-depends-on='nix-store --query --referrers'
    alias day='date "+%Y-%m-%d"'
    alias grep='grep --color=auto'
    alias tmp='cd "$(mktemp -d)"'
  '' +
  # compatibility for programs that need $NIX_PATH set:
  lib.concatMapStrings
    (x: ''
      alias ${x}='NIX_PATH="nixpkgs=$(nix eval nixpkgs#path)" ${x}'
    '')
    [
      "nix-build"
      "nix-index"
      "nix-prefetch-github"
      "nix-shell"
    ];
}
