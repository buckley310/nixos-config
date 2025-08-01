{
  config,
  lib,
  pkgs,
  ...
}:
{
  time.timeZone = "America/New_York";

  # the default is all languages. this just shrinks the install size
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  # makes system evaluation much faster
  documentation.nixos.enable = false;

  boot = {
    zfs.forceImportRoot = false;
    initrd.availableKernelModules = [ "nvme" ];
    kernelParams = [
      "amdgpu.gpu_recovery=1"
      "nohibernate"
      "panic=99"
      "sysctl.vm.overcommit_memory=1"
    ];
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    # builtins.trace "unfree: ${lib.getName pkg}" (
    builtins.elem (lib.getName pkg) [
      "cuda_cudart"
      "libcublas"
      "cuda_cccl"
      "cuda_nvcc"
      "nvidia-x11"
      "vscode-with-extensions"
      "vscode"
      "burpsuite"
      "terraform"
      "discord"
      "discord-gamesdk"
      "steam"
      "steam-unwrapped"
      "nvidia-settings"
    ];

  security.sudo.extraConfig = "Defaults lecture=never";

  security.sudo.wheelNeedsPassword = false;

  systemd.oomd.enable = false; # using earlyoom

  services.speechd.enable = false;

  zramSwap.enable = lib.mkDefault true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  nix = {
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      experimental-features = "nix-command flakes";
      keep-build-log = false;
    };
  };

  services = {
    earlyoom.enable = true;
    logind.lidSwitch = "ignore";
    openssh.enable = true;
    libinput.mouse.middleEmulation = false;
    xserver = {
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    smartmontools
    sshfs
  ];
}
