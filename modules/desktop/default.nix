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
      bruno
      discord
      easyeffects
      element-desktop
      ffmpeg
      gimp
      glxinfo
      dconf-editor
      helvum
      obs-studio
      opensc
      pavucontrol
      qemu_kvm
      tdesktop
      thunderbird
      yt-dlp-light

      xsel # allow editors to access system clipboard

      (mpv.override { scripts = [ mpvScripts.mpris ]; })
    ];

  };
}
