{ lib, ... }:
{
  options.deploy = {
    ssh = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
