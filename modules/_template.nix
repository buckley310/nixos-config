{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig._options_name_;
in
{
  options.sconfig._options_name_ = lib.mkEnableOption "Do a Barrel Roll";
  options.sconfig._options_name_ = lib.mkOption {
    default = true;
    type = lib.types.bool;
    description = "Do a Barrel Roll";
  };

  config = lib.mkIf cfg {
    environment.systemPackages = with pkgs; [ hello ];
  };
}
