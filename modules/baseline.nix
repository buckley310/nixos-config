{ config, pkgs, lib, ... }:
{
  time.timeZone = "US/Eastern";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  boot = {
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
    kernelParams = [ "amdgpu.gpu_recovery=1" "panic=30" ];
    initrd.availableKernelModules = [ "nvme" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  systemd.tmpfiles.rules = [
    "e /nix/var/log - - - 30d"
    "e /home/sean/Downloads - - - 9d"
  ];

  zramSwap.enable = true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
  };

  services = {
    earlyoom.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      publish.enable = true;
      publish.addresses = true;
    };
  };

  systemd.timers.nixosReport.timerConfig.RandomizedDelaySec = "55min";
  systemd.services.nixosReport = {
    startAt = "hourly";
    serviceConfig.Type = "simple";
    serviceConfig.ExecStart = lib.concatStringsSep " " [
      "${pkgs.curl}/bin/curl --silent https://log.bck.me/nixos-report"
      "-H 'hostname: ${config.networking.hostName}'"
      "-H 'version: ${config.system.nixos.label}'"
      "-H 'sconfig: ${builtins.toJSON config.sconfig}'"
    ];
  };

  users.users.sean = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh1MVRPld8lg8U7j4QwurxkTGLd4EYEn+JaplqXMqNW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtTBrVXCDelPYUeUzFSLhWtBDI8IO6HVpX4ewUxD+Nc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLZgFlJTT8wFz2DGeB1YETKPvm63/u1kT7pzranCoqP"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbQPpgGWF2qsgiL2YlBMd3JyJ2fbksfykuDNJYrHWfO dell_laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqEgH/+Fcp7x9ipp4Rwy8uD8klMR54kMXt2k7gGlrPR sean@tosh"
    ];
  };
}
