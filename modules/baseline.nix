{ config, pkgs, ... }:
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

  zramSwap.enable = true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  # lower ipv4 DNS priority for networkmanager
  networking.networkmanager.extraConfig = ''
    [connection]
    ipv4.dns-priority=101
  '';

  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
    package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    openssh.startWhenNeeded = true;
    earlyoom.enable = true;

    xserver = {
      libinput.mouse.middleEmulation = false;
      deviceSection = ''
        Option "VariableRefresh" "true"
      '';
    };

    avahi = {
      enable = true;
      nssmdns = true;
      publish.enable = true;
      publish.addresses = true;
    };
  };
}
