{ pkgs, ... }:
let
  persist = "/nix/persist";
in
{
  environment.etc = {
    "machine-id".source = "${persist}/machine-id";
  };

  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "${persist}/ssh_host_ed25519_key";
    }
  ];

  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";
  # };
  # programs.bash.interactiveShellInit = ''
  #   alias ai='ollama run llama3.1:8b'
  # '';

  sconfig = {
    gnome = true;
    desktop.enable = true;
    wg-home = {
      enable = true;
      path = "${persist}/wireguard_home.conf";
    };
  };

  environment.persistence."${persist}/system".directories = [
    "/etc/NetworkManager/system-connections"
    "/tmp"
    "/var/lib/bluetooth"
    "/var/lib/nixos"
    "/var/lib/private"
    "/var/lib/systemd/coredump"
    "/var/log/journal"
    "/var/tmp"
  ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "eco" ''
      exec taskset ff000 "$@"
    '')
  ];

  nix.extraOptions = ''
    extra-platforms = i686-linux
  '';

  boot = {
    loader.systemd-boot.enable = true;
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
      fsType = "vfat";
      device = "/dev/nvme0n1p1";
    };
    "/nix" = {
      device = "levi/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "levi/home";
      fsType = "zfs";
    };
  };

  users.mutableUsers = false;
  users.users.sean.hashedPasswordFile = "${persist}/shadow_sean";
  users.users.root.hashedPasswordFile = "${persist}/shadow_sean";

  services.zfs.trim.interval = "03:05";

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "22.05";
}
