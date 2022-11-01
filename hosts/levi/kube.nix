{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  environment.systemPackages = [ pkgs.kubectl ];
  services.k3s.enable = true;
}
