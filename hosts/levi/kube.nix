{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  environment.systemPackages = [
    pkgs.kubectl
    pkgs.kubernetes-helm
  ];
  services.k3s.enable = true;
  services.k3s.extraFlags = toString [
    # flags for using Calico instead of Flannel
    "--disable-network-policy"
    "--flannel-backend=none"
  ];
}
