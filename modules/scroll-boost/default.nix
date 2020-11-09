{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      xorg = super.xorg.overrideScope' (selfB: superB: {
        inherit (super.xorg) xlibsWrapper;
        xf86inputlibinput = superB.xf86inputlibinput.overrideAttrs (attr: {
          patches = [ ./libinput.patch ];
        });
      });
    })
  ];
}
