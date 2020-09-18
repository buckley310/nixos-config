{ config, pkgs, ... }:
{
    users.users = {
        sean = {
            isNormalUser = true;
            uid = 1000;
            extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
        };
        test = {
            isNormalUser = true;
            isSystemUser = true;
        };
    };
}
