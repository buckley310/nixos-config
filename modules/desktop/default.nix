{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  options.sconfig.desktop = {
    enable = lib.mkEnableOption "Enable Desktop Environment";
  };

  imports = [
    ./alacritty.nix
    ./chromium.nix
    ./firefox.nix
    ./foot.nix
  ];

  config = mkIf (config.sconfig.desktop.enable) {
    programs.steam.enable = true;
    networking.networkmanager.wifi.powersave = false;

    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
      # daemon.settings = {
      #   data-root = "/nix/persist/docker";
      #   runtimes.runsc.path = "${pkgs.gvisor}/bin/runsc";
      # };
    };

    services.udev.packages = [
      pkgs.zsa-udev-rules
    ];

    # Pipewire
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    sconfig = {
      devtools.enable = true;
      security-tools = true;
    };

    fonts.packages = [
      pkgs.nerd-fonts.dejavu-sans-mono
    ];

    environment.systemPackages = with pkgs; [
      _86Box-with-roms
      dconf-editor
      discord
      easyeffects
      element-desktop
      feh
      ffmpeg
      gimp
      helvum
      obs-studio
      pavucontrol
      qemu_kvm
      telegram-desktop
      thunderbird
      wl-clipboard
      yt-dlp-light

      (mpv.override { scripts = [ mpvScripts.mpris ]; })

      # Quick way to make Feh preferred by XDG
      (runCommand "feh-helper" { } ''
        install -D \
          '${feh}/share/applications/feh.desktop' \
          "$out/share/applications/aaa-feh.desktop"
      '')
    ];

    environment.etc."feh/buttons".text = ''
      toggle_menu 2
      zoom 3
    '';
    environment.etc."feh/themes".text = ''
      feh --auto-zoom --scale-down
    '';

  };
}
