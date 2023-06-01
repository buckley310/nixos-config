lib:

{ system, modules ? [ ] }:

let
  cd-minimal = { modulesPath, ... }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  };

  sys = lib.nixosSystem {
    inherit system;
    modules = [ cd-minimal ] ++ modules;
  };

in
sys.config.system.build.isoImage
