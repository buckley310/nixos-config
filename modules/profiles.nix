{ lib, ... }:
with lib;
{
  options.sconfig.profile = mkOption {
    type = types.enum [ "server" "desktop" ];
  };
}
