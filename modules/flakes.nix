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

    system.autoUpgrade.flake = cfg.rebuildPath;
    system.autoUpgrade.flags = [ (lib.optionalString (cfg.rebuildPath == "/etc/nixos") "--recreate-lock-file") ];

    environment.systemPackages = map
      (x: (pkgs.writeShellScriptBin
        "sc-${builtins.head x}"
        "nixos-rebuild ${lib.concatStringsSep " " (builtins.tail x)} --flake ${cfg.rebuildPath}"
      ))
      [
        [ "switch" "switch" ]
        [ "build" "build" ]
        [ "boot" "boot" ]
        [ "switch-upgrade" "switch" (if cfg.rebuildPath == "/etc/nixos" then "--recreate-lock-file" else "--refresh") ]
        [ "build-upgrade" "build" (if cfg.rebuildPath == "/etc/nixos" then "--recreate-lock-file" else "--refresh") ]
        [ "boot-upgrade" "boot" (if cfg.rebuildPath == "/etc/nixos" then "--recreate-lock-file" else "--refresh") ]
      ];

  };
}
