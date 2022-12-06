{ config, lib, pkgs, ... }:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlMPWSVyDNAvXYtpXCI/geCeUEMbL9Nthm9B0zg1sIy sean@hp"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuuBHq3x28cdQ0JWAZ0R+2rVlRoPnA+MOvpdF5rraGp sean@lenny"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE59uvHtxmdjqMaKyPiKLdiwfu0i59iFczrbGY0t6Oed sean@levi"
  ];
in
{
  users.users.root.openssh.authorizedKeys.keys =
    lib.optionals (config.sconfig.profile == "server") keys;

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
    openssh.authorizedKeys = { inherit keys; };
  };

  systemd.tmpfiles.rules = [ "e /home/sean/Downloads - - - 9d" ];

  environment.systemPackages =
    [
      (pkgs.writeShellScriptBin "sc-check" ''
        out="$(mktemp -d)"
        nix build -o "$out/out" \
          "bck#nixosConfigurations.$(hostname).config.system.build.toplevel"
        readlink /run/current-system "$out/out"
        rm -r "$out"
      '')
    ]
    ++ map
      (x: (pkgs.writeShellScriptBin "sc-${x}" "nixos-rebuild ${x} --refresh --flake bck"))
      [ "boot" "build" "switch" "test" ];

  environment.etc."my-settings.sh".text = ''
    git config --global user.email "sean.bck@gmail.com"
    git config --global user.name "Sean Buckley"
  '';
}
