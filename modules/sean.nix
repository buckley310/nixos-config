{ config, lib, pkgs, ... }:
{
  users.users.sean = {
    uid = 2000;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "dialout"
      "input"
      "networkmanager"
      "video"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = import ../lib/ssh-keys.nix;
  };

  systemd.tmpfiles.rules = [ "e /home/sean/Downloads - - - 9d" ];

  environment.etc."my-settings.sh".text = ''
    git config --global user.email "sean.bck@gmail.com"
    git config --global user.name "Sean Buckley"
  '';
}
