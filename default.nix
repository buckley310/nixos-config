{ ... }:
{
  imports = [
    ./modules/alacritty.nix
    ./modules/backports.nix
    ./modules/baseline.nix
    ./modules/cli.nix
    ./modules/fix-gnome-mouse-lag.nix
    ./modules/flakes.nix
    ./modules/phpipam.nix
    ./modules/profiles.nix
    ./modules/scansnap_s1300.nix
    ./modules/scroll-boost
    ./modules/status-on-console.nix
    ./security-tools.nix
  ];
}
