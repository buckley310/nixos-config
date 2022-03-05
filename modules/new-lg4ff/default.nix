{ config, lib, pkgs, ... }:
let
  cfg = config.sconfig.new-lg4ff;
in
{
  options.sconfig.new-lg4ff.enable = lib.mkEnableOption "Enable new-lg4ff";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "hid-logitech-new" ];
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./pkg.nix { })
    ];
  };
}
