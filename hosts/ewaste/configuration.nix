{ ... }:
{
  sconfig.desktop.enable = true;
  sconfig.hypr.enable = true;

  networking.networkmanager.enable = true;

  environment.etc = {
    "machine-id".source = "/persist/machine-id";
  };

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/persist/ssh_host_ed25519_key";
    }
  ];

  environment.persistence."/persist/system".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
    "/var/log/journal"
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };
    "/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
    };
    "/nix" = {
      device = "tank/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "tank/home";
      fsType = "zfs";
    };
    "/persist" = {
      device = "tank/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  users.mutableUsers = false;
  users.users.sean.hashedPasswordFile = "/persist/shadow_sean";
  users.users.root.hashedPasswordFile = "/persist/shadow_sean";

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
