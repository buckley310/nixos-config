{ config, lib, pkgs, ... }:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlMPWSVyDNAvXYtpXCI/geCeUEMbL9Nthm9B0zg1sIy sean@hp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuuBHq3x28cdQ0JWAZ0R+2rVlRoPnA+MOvpdF5rraGp sean@lenny"
  ];
in
{
  users.users.root.openssh.authorizedKeys.keys =
    lib.optionals (config.sconfig.profile == "server") keys;

  users.users.sean = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
    openssh.authorizedKeys = { inherit keys; };
  };

  systemd.tmpfiles.rules = [ "e /home/sean/Downloads - - - 9d" ];

  environment.systemPackages = map
    (x: (pkgs.writeShellScriptBin "sc-${x}" "nixos-rebuild ${x} --refresh --flake github:buckley310/nixos-config"))
    [ "boot" "build" "switch" "test" ];

  sconfig.user-settings = ''
    git config --global user.email "sean.bck@gmail.com"
    git config --global user.name "Sean Buckley"
  '';
}
