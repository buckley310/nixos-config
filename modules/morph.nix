{ lib, ... }:
with lib.types;
{
  options.sconfig.morph = {

    sshPublicKeys = lib.mkOption {
      type = listOf str;
      default = [ ];
    };

    deployment = lib.mkOption {
      type = attrs;
      default = { };
    };

  };
}
