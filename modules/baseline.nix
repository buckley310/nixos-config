{ config, pkgs, ... }:
{
  time.timeZone = "US/Eastern";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  boot = {
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
    kernelParams = [ "amdgpu.gpu_recovery=1" "panic=30" ];
    initrd.availableKernelModules = [ "nvme" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  environment.systemPackages = map
    (x: (pkgs.writeShellScriptBin "sc-${x}" "nixos-rebuild ${x} --refresh --flake github:buckley310/nixos-config"))
    [ "switch" "build" "boot" ];

  systemd.tmpfiles.rules = [
    "e /nix/var/log - - - 30d"
    "e /home/sean/Downloads - - - 9d"
  ];

  zramSwap.enable = true;

  networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

  nix = {
    daemonNiceLevel = 19;
    daemonIONiceLevel = 7;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
  };

  services.xserver = {
    libinput.mouse.middleEmulation = false;
    deviceSection = ''
      Option "VariableRefresh" "true"
    '';
  };

  services = {
    earlyoom.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      publish.enable = true;
      publish.addresses = true;
    };
  };

  users.users.sean = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "dialout" "input" "wireshark" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqWHzIXaF88Y8+64gBlLbZ5ZZcLl08kTHG1clHd7gaq desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh1MVRPld8lg8U7j4QwurxkTGLd4EYEn+JaplqXMqNW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtTBrVXCDelPYUeUzFSLhWtBDI8IO6HVpX4ewUxD+Nc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLZgFlJTT8wFz2DGeB1YETKPvm63/u1kT7pzranCoqP"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbQPpgGWF2qsgiL2YlBMd3JyJ2fbksfykuDNJYrHWfO dell_laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJqEgH/+Fcp7x9ipp4Rwy8uD8klMR54kMXt2k7gGlrPR sean@tosh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPt766Pb4vXwGMzhnS4qXJDfkH8Ia1T1TCoCcR/asxMg sean@lenny"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChhSNkLZXM7f8BUWdQDv63YL0feN2webGwA+ocpUnwm2mw/o/g+9SNaK7wOQoqDVjrS6yx4Mf2e8+6ZweM6Q2cT1uYSaipaclFR/xuyOeoWwEcRkFZ5O32OlRc3VoRYj8HPDYUsJn77hMlUmA6JEb6+rT4o6uEjDjgRP0bpLtDzPXNsCBFlVX0tUYE1WUirTL5n20KhJLe5/dAEkL8469nijcWcYCD7xpWrkEUK6j13v5wGfo4iujeeZUw5oU4O8tap+9gDHnRz3wtuZPq9qHOPQ2FqrvjWyagyQBhkU//09dCeKMAReeFrYk2XtGqeypTxmjpwXotjk8v36iAdvm/ PIVKey"
    ];
  };
}
