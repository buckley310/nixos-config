{ ... }:
{
  imports = [
    ../modules/auto-update.nix
    ../modules/baseline.nix
    ../modules/cli.nix
  ];
  services.openssh.enable = true;
}
