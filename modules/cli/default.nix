{ lib, pkgs, ... }:
{
  imports = [
    ./lf.nix
    ./powerline.nix
  ];

  environment.systemPackages = with pkgs; [
    bat
    bc
    dnsutils
    dust
    entr
    file
    helix
    iftop
    inetutils
    iotop
    jq
    lm_sensors
    ncdu
    nix-diff
    nixfmt-rfc-style
    nix-index
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
    yq-go
    zip

    (writeShellScriptBin "dirt" "while sleep 1; do grep '^Dirty:' /proc/meminfo ; done")

    (lib.hiPrio (
      writeShellScriptBin "iftop" ''
        exec ${iftop}/bin/iftop -P -m100M "$@"
      ''
    ))

    (writeShellScriptBin "hd" ''
      exec hexdump -C "$@"
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

    (writeShellScriptBin "nix-latest" ''
      cd ~/git/nixpkgs
      git fetch origin nixos-unstable
      git show  origin/nixos-unstable
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
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 10000;
    terminal = "screen-256color";
    extraConfig = ''
      bind-key j command-prompt -p "Join pane:"  "join-pane -s '%%'"
      bind-key '_' split-window -v -c "#{pane_current_path}"
      bind-key '|' split-window -h -c "#{pane_current_path}"
      bind-key -n C-n new-window   -c "#{pane_current_path}"
      bind-key -n C-j previous-window
      bind-key -n C-k next-window
      bind-key -n C-h select-pane -t -1
      bind-key -n C-l select-pane -t +1
      bind-key -n S-Pagedown copy-mode \; send-keys -X halfpage-down
      bind-key -n S-Pageup   copy-mode \; send-keys -X halfpage-up
      set -g renumber-windows on
      set -g set-titles on
      set -sa terminal-overrides ",*256color:Tc"
      set-window-option -g mode-keys vi
    '';
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias h=htop
    alias tree='tree -I .git'
    alias nix-what-depends-on='nix-store --query --referrers'
    alias day='date "+%Y-%m-%d"'
    alias grep='grep --exclude-dir=.git --color=auto'
    alias tmp='cd "$(mktemp -d)"'
    alias nixpkgs='nix repl --file flake:nixpkgs'
    ${builtins.readFile ./osc7cwd.sh}
    osc133a_prompt_marker() {
      printf '\e]133;A\e\\'
    }
    PROMPT_COMMAND="osc133a_prompt_marker; $PROMPT_COMMAND"
  '';
}
