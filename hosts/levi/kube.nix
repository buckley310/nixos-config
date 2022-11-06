{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  environment.systemPackages = [ pkgs.kubectl ];
  services.k3s.enable = true;

  # Get NetworkPolicy working
  networking.firewall.enable = false;
  systemd.services.k3s.path = [ pkgs.ipset ];
  services.k3s.package = pkgs.k3s.overrideAttrs (prev: {
    buildInputs = prev.buildInputs ++ [ pkgs.ipset ];
  });
}
