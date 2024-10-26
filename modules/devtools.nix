{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.devtools;
in
{
  options.sconfig.devtools.enable = lib.mkEnableOption "Development Tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        rustc.llvmPackages.lld
      ];
  };
}
