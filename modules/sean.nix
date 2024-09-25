{ pkgs, ... }:
{
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = [
    pkgs.bck-nvim-base
    pkgs.bck-nvim-tools
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

  systemd.tmpfiles.rules = [ "e /home/sean/Downloads - - - 9d" ];

  environment.etc."bck-settings.sh".text = ''
    git config --global user.email "sean.bck@gmail.com"
    git config --global user.name "Sean Buckley"
  '';

  users.users.zim = {
    uid = 2099;
    isNormalUser = true;
  };
}
