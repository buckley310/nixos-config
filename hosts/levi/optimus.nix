{ lib, pkgs, ... }:
let
  current-mode = "nvidia-mux";

  constants = {
    hardware.nvidia.prime.intelBusId = "PCI:0:2:0";
    hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
    boot.kernelPackages = pkgs.linuxPackages_6_0;
    boot.zfs.enableUnstable = true; # TODO: remove
  };

  available-modes = {

    nvidia = {
      ### "sync mode"
      #
      # good:
      #   max performance on external displays
      #   no BIOS settings change needed
      #
      # bad:
      #   graphics performance overhead on internal display
      #   internal display capped at 60hz
      #
      hardware.nvidia.prime.sync.enable = true;
      hardware.nvidia.modesetting.enable = true;
      services.xserver.displayManager.gdm.wayland = false;
      services.xserver.videoDrivers = [ "nvidia" ];
      # xrandr workaround for laptop panel not showing up with GDM. Reference:
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/video/nvidia.nix
      services.xserver.displayManager.sessionCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
      '';
    };

    nvidia-mux = {
      ### optimus disabled in BIOS with MUX switch.
      #
      # good:
      #   simple, always works.
      #   max performance everywhere.
      #
      # bad:
      #   cant change laptop brightness.
      #   requires BIOS setting changes, which is annoying.
      #
      boot.kernelParams = [ "module_blacklist=i915" ];
      services.xserver.videoDrivers = [ "nvidia" ];
    };

    intel = {
      ### nvidia drivers disabled
      #
      # Not well tested. Possibly Incomplete.
      # Won't allow external displays connected to nvidia GPU.
      #
      # Shutting off Nvidia GPU would theoretically save power.
      # I do not think this actually powers down the Nvidia GPU, just stops using it.
      #
      boot.kernelParams = [ "module_blacklist=nouveau" ];
    };

    hybrid = {
      ### hybrid graphics
      #
      # Not well tested. Possibly Incomplete.
      # Won't allow external displays connected to nvidia GPU.
      #
      # Everything would use intel by default,
      # but specific apps would run on the nvidia GPU under the script.
      #
      hardware.nvidia.prime.offload.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "nv" ''
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export __VK_LAYER_NV_optimus=NVIDIA_only
          exec "$@"
        '')
      ];
    };

  };

in
lib.mkMerge [
  (constants)
  (available-modes.${current-mode})
]
