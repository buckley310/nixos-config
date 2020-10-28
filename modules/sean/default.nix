{ config, pkgs, ... }:
{
  users.users = {
    sean = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALNzkn63+7jlmGk68bj03A4Ym7aBdPTODq+QHyYULfO"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtTBrVXCDelPYUeUzFSLhWtBDI8IO6HVpX4ewUxD+Nc"
      ];
    };
    test = {
      isNormalUser = true;
      isSystemUser = true;
    };
  };
}
