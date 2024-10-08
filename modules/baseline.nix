{ config, lib, ... }:
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

  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = "Defaults lecture=never";

  systemd.tmpfiles.rules = [ "e /nix/var/log - - - 30d" ];

  systemd.oomd.enable = false; # using earlyoom

  zramSwap.enable = lib.mkDefault true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  networking.usePredictableInterfaceNames = lib.mkDefault false;

  nix = {
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    earlyoom.enable = true;
    logind.lidSwitch = "ignore";
    openssh.enable = true;
    openssh.startWhenNeeded = true;
    libinput.mouse.middleEmulation = false;
    xserver = {
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';
    };
  };
}
