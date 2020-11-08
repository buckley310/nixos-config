{ config, pkgs, ... }:
{
  users.users = {
    sean = {
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh1MVRPld8lg8U7j4QwurxkTGLd4EYEn+JaplqXMqNW"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtTBrVXCDelPYUeUzFSLhWtBDI8IO6HVpX4ewUxD+Nc"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLZgFlJTT8wFz2DGeB1YETKPvm63/u1kT7pzranCoqP"
      ];
    };
    test = {
      isNormalUser = true;
      isSystemUser = true;
    };
  };
}
