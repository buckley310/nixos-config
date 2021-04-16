{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.flakes;
in
{
  options.sconfig.flakes = {
    enable = lib.mkEnableOption "Enable Flakes";
    rebuildPath = lib.mkOption {
      default = "/etc/nixos";
      type = lib.types.str;
      description = "Flake to use when running nixos-rebuild helper scripts";
    };
  };

  config = lib.mkIf cfg.enable {

    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    environment.systemPackages = map
      (x: (pkgs.writeShellScriptBin "sc-${x}" "nixos-rebuild ${x} --refresh --flake ${cfg.rebuildPath}"))
      [ "switch" "build" "boot" ];

  };
}
