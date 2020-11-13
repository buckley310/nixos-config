{ config, pkgs, lib, ... }:
{
  time.timeZone = "US/Eastern";

  boot = {
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
    kernelParams = [ "amdgpu.gpu_recovery=1" "panic=30" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  systemd.tmpfiles.rules = [ "e /nix/var/log - - - 30d" ];

  zramSwap.enable = true;

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
      "-H 'imports: ${lib.concatMapStringsSep " " toString (pkgs.callPackage /etc/nixos/configuration.nix { }).imports}'"
    ];
  };
}
