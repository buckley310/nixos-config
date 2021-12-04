{ pkgs, ... }:
{
  sconfig = {
    gnome = true;
    profile = "desktop";
    hardware = "physical";
  };

  environment.etc =
    builtins.listToAttrs (map
      (name: { inherit name; value.source = "/persist/etc/${name}"; })
      [
        "machine-id"
        "ssh/ssh_host_ed25519_key"
        "ssh/ssh_host_rsa_key"
      ]);

  environment.systemPackages = with pkgs; [
    wine
    vmware-horizon-client
  ];

  services.openssh.enable = true;

  users.mutableUsers = false;
  users.users.sean.passwordFile = "/persist/shadow/sean";
  users.users.root.passwordFile = "/persist/shadow/sean";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = map (x: "video=DP-${x}:1280x720@60") [ "0" "1" "2" ];
  };

  fileSystems = {
    "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
    "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; };
    "/nix" = { device = "cube/locker/nix"; fsType = "zfs"; };
    "/persist" = { device = "cube/locker/persist"; fsType = "zfs"; neededForBoot = true; };
  }
  // builtins.listToAttrs (map
    (name: { inherit name; value = { device = "/persist${name}"; noCheck = true; options = [ "bind" ]; }; })
    [ "/home" "/var/log" ]);

  system.stateVersion = "21.05";
}
