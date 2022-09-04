{ config, lib, pkgs, ... }:
{
  time.timeZone = "US/Eastern";

  # the default is all languages. this just shrinks the install size
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  boot = {
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
    kernelParams = [ "amdgpu.gpu_recovery=1" "panic=30" ];
    initrd.availableKernelModules = [ "nvme" ]; # is this still needed?
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  security.sudo.extraConfig = "Defaults lecture=never";

  systemd.tmpfiles.rules = [ "e /nix/var/log - - - 30d" ];

  programs.ssh.hostKeyAlgorithms = [ "ssh-ed25519" ];

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
    openssh.startWhenNeeded = true;
    earlyoom.enable = true;

    xserver = {
      libinput.mouse.middleEmulation = false;
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';
    };
  };
}
