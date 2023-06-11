{ lib, ... }:
{
  options.deploy = {
    sshPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    ssh = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
}
