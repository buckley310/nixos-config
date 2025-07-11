{ lib, pkgs, ... }:
{
  imports = [
    ./powerline.nix
  ];

  environment.systemPackages = with pkgs; [
    bat
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
    yq
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

    (writeShellScriptBin "runvm-lin" (toString [
      "exec ${pkgs.qemu_kvm}/bin/qemu-kvm"
      "-bios ${pkgs.OVMF.fd}/FV/OVMF.fd"
      "-cpu host"
      "-smp cores=4"
      "-m 4G"
      "-usbdevice tablet"
      "-rtc base=utc"
      "-vga virtio"
      "\"$@\""
    ]))

    (writeShellScriptBin "runvm-win" (toString [
      "exec ${pkgs.qemu_kvm}/bin/qemu-kvm"
      "-bios ${pkgs.OVMF.fd}/FV/OVMF.fd"
      "-cpu host"
      "-smp cores=4"
      "-m 4G"
      "-usbdevice tablet"
      "-rtc base=localtime"
      "-vga qxl"
      "\"$@\""
    ]))

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
    '';
  };

  programs.bash.interactiveShellInit = ''
    stty -ixon
    alias p=python3
    alias h=htop
    alias nix-what-depends-on='nix-store --query --referrers'
    alias day='date "+%Y-%m-%d"'
    alias grep='grep --color=auto'
    alias tmp='cd "$(mktemp -d)"'
    alias nixpkgs='nix repl --file flake:nixpkgs'
  '';
}
