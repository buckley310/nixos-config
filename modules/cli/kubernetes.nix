{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # dedicated script, because bash aliases dont work with `watch`
  ];
}
