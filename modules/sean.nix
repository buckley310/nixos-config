{ pkgs, ... }:
{
  environment.variables.EDITOR = "hx";
  environment.systemPackages = [
    pkgs.bck-nvim
  ];

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

  environment.etc."bck-settings.sh".text = ''
    git config --global user.email "sean.bck@gmail.com"
    git config --global user.name "Sean Buckley"
  '';

  users.users.zim = {
    uid = 2099;
    isNormalUser = true;
  };
}
