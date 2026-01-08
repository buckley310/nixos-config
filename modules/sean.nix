{ pkgs, ... }:
{
  environment.variables.EDITOR = "hx";

  users.users.sean = {
    uid = 2000;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "input"
      "networkmanager"
      "video"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = import ../lib/ssh-keys.nix;
  };

  users.users.zim = {
    uid = 2099;
    isNormalUser = true;
  };
}
