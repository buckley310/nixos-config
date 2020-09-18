{ config, pkgs, ... }:
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

    zramSwap = {
        enable = true;
        algorithm = "zstd";
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
}
