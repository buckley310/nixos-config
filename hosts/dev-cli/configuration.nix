{ ... }:
{
  sconfig.profile = "server";
  services.getty.autologinUser = "root";
  fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };
  boot.loader.grub.device = "nodev";
}
