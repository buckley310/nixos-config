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
      (x: (pkgs.writeShellScriptBin
        "sc-${builtins.head x}"
        "nixos-rebuild ${lib.concatStringsSep " " (builtins.tail x)} --flake ${cfg.rebuildPath}"
      ))
      [
        [ "switch" "switch" ]
        [ "build" "build" ]
        [ "boot" "boot" ]
        [ "switch-upgrade" "switch" "--recreate-lock-file" "--refresh" ]
        [ "build-upgrade" "build" "--recreate-lock-file" "--refresh" ]
        [ "boot-upgrade" "boot" "--recreate-lock-file" "--refresh" ]
      ];

  };
}
