{ pkgs, ... }:
{
  sconfig.desktop.enable = true;
  sconfig.hypr.enable = true;

  environment.etc = {
    "machine-id".source = "/persist/machine-id";
  };

  # services.blueman.enable = true;
  # hardware.bluetooth.enable = true;

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/persist/ssh_host_ed25519_key";
    }
  ];

  environment.persistence."/persist/system".directories = [
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/private"
    "/var/lib/systemd/coredump"
    "/var/log/journal"
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "vmd"
      "nvme"
      "sd_mod"
    ];
  };

  fileSystems = {
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/BC7D-DF98";
      fsType = "vfat";
    };
    "/nix" = {
      device = "obsidian/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "obsidian/home";
      fsType = "zfs";
    };
    "/persist" = {
      device = "obsidian/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  users.mutableUsers = false;
  users.users.sean.hashedPasswordFile = "/persist/shadow_sean";
  users.users.root.hashedPasswordFile = "/persist/shadow_sean";

  services.zfs.trim.interval = "05:05";
  services.zfs.trim.randomizedDelaySec = "50min";

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
