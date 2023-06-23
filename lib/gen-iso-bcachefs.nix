lib:
system:

let
  sys = lib.nixosSystem {
    inherit system;
    modules = [
      ({ modulesPath, pkgs, ... }: {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
        ];
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing_bcachefs;
        boot.supportedFilesystems = [ "bcachefs" ];
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";
      })
    ];
  };

in
sys.config.system.build.isoImage
