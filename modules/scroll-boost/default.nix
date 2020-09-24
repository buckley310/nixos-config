{ config, pkgs, ... }:
{
  services.xserver.displayManager.sessionCommands = ''
    xinput list | cut -d= -f2 | cut -f1 | xargs -i xinput set-prop {} 'libinput Scroll Distance Scale' 2 1
  '';

  nixpkgs.overlays = [
    (self: super: {
      xorg = super.xorg.overrideScope' (selfB: superB: {
        inherit (super.xorg) xlibsWrapper;
        xf86inputlibinput = superB.xf86inputlibinput.overrideAttrs (attr: {
          patches = [ ./b7b5c5ef5f34802fc5f57e68493afaea5db7cdb4.diff ];
        });
      });
    })
  ];
}
