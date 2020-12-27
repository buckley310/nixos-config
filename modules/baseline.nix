{ config, pkgs, lib, ... }:
{
  imports = [ ./backports.nix ];

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

  users.users.sean = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh1MVRPld8lg8U7j4QwurxkTGLd4EYEn+JaplqXMqNW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtTBrVXCDelPYUeUzFSLhWtBDI8IO6HVpX4ewUxD+Nc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLZgFlJTT8wFz2DGeB1YETKPvm63/u1kT7pzranCoqP"
    ];
  };
}
