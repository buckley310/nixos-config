{ config, lib, pkgs, ... }:
{
  time.timeZone = "US/Eastern";

  # the default is all languages. this just shrinks the install size
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  boot = {
    zfs.forceImportRoot = false;
    initrd.availableKernelModules = [ "nvme" ]; # is this still needed?
    kernelParams = [
      "amdgpu.gpu_recovery=1"
      "nohibernate"
      "panic=99"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = "Defaults lecture=never";

  systemd.tmpfiles.rules = [ "e /nix/var/log - - - 30d" ];

  zramSwap.enable = lib.mkDefault true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  nix = {
    nixPath = [ ];
    daemonCPUSchedPolicy = "idle";
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    openssh.enable = true;
    xserver = {
      libinput.mouse.middleEmulation = false;
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';
    };
  };
}
