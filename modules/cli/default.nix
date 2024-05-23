{ lib, pkgs, ... }:
{
  imports = [
    ./kubernetes.nix
    ./powerline.nix
  ];

  environment.systemPackages = with pkgs; [
    darkhttpd
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

    (writeShellScriptBin "hd" ''
      exec hexdump -C "$@"
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
    package = pkgs.htop.overrideAttrs (
      { patches ? [ ], ... }: {
        patches = patches ++ [
          # This patch fixes process sort order while in tree view.
          # Started in 3.3.0. Should be fixed in 3.4.0.
          (pkgs.fetchpatch {
            url = "https://github.com/htop-dev/htop/commit/5d778eaacc78c69d5597b57afb4f98062d8856ef.patch";
            hash = "sha256-bjIYve2cAQNYKOYqQcVrw3aJs9ceanjfv0Y9yRwNlvg=";
          })
        ];
      }
    );
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
      set -g history-limit 10000
      set -g pane-base-index 1
      set -g renumber-windows on
      set -sa terminal-overrides ",*256color:Tc"
      # escape-time reduces the time where the escape key acts as an alt key
      set -s escape-time 1
      ################################################################################
      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias jq='jq --indent 4'
    alias yq='yq --indent 4'
    alias p=python3
    alias h=htop
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
