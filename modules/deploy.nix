{ lib, ... }:
{
  options.deploy = {
    sshPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    targetHost = lib.mkOption {
      type = lib.types.str;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
