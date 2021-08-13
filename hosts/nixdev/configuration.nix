{ ... }:
{
  sconfig = {
    profile = "server";
  };

  environment.persistence."/nix/persist" = {
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
    directories = [
      "/home"
      "/var/log"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    useDHCP = false;
    interfaces.enp6s18.ipv4.addresses = [{ address = "10.5.7.160"; prefixLength = 24; }];
    defaultGateway = "10.5.7.1";
    nameservers = [ "1.1.1.1" ];
  };

  fileSystems =
    {
      "/" = { device = "tmpfs"; fsType = "tmpfs"; options = [ "mode=755" ]; };
      "/boot" = { device = "/dev/disk/by-partlabel/_esp"; fsType = "vfat"; options = [ "discard" "noatime" ]; };
      "/nix" = { device = "/dev/disk/by-partlabel/_nix"; fsType = "ext4"; options = [ "discard" "noatime" ]; };
    };

  system.stateVersion = "21.05";
}
