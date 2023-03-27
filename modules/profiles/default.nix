{ lib, ... }:
with lib;
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "desktop" ];
  };
  imports = [ ./desktop.nix ];
}
