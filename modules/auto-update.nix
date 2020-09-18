{ config, pkgs, ... }:
{
    system.autoUpgrade = {
        enable = true;
        allowReboot = true;
    };
    nix.gc = {
        automatic = true;
        options = "--delete-older-than 30d";
    };
}
