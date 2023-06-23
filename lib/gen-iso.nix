lib:
system:

let
  sys = lib.nixosSystem {
    inherit system;
    modules = [
      ({ modulesPath, ... }: {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";
      })
    ];
  };

in
sys.config.system.build.isoImage
