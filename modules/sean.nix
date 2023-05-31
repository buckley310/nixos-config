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
