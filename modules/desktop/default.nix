{ config, pkgs, lib, ... }:
with lib;
{
  options.sconfig.desktop = {
    enable = lib.mkEnableOption "Enable Desktop Environment";
  };

  imports = [
    ./alacritty.nix
    ./chromium.nix
    ./firefox.nix
    ./vscode.nix
  ];

  config = mkIf (config.sconfig.desktop.enable) {
    programs.steam.enable = true;
    networking.networkmanager.wifi.powersave = false;

    systemd.services.docker.path = [
      pkgs.openssh
    ];
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        data-root = "/nix/persist/docker";
        runtimes.runsc.path = "${pkgs.gvisor}/bin/runsc";
      };
    };

    # Pipewire
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    sconfig = {
      security-tools = true;
    };

    services.udev.extraHwdb = ''
      mouse:usb:*
        MOUSE_DPI=600@1000
    '';

    fonts.packages = [
      (pkgs.nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
    ];

    environment.systemPackages = with pkgs; [
      discord
      easyeffects
      element-desktop
      ffmpeg
      gimp
      glxinfo
      dconf-editor
      helvum
      kdenlive
      obs-studio
      opensc
      pavucontrol
      qemu_kvm
      quickemu
      tdesktop
      yt-dlp-light

      xsel # allow editors to access system clipboard

      (mpv.override { scripts = [ mpvScripts.mpris ]; })
    ];

    boot.loader.timeout = 1;
  };
}
