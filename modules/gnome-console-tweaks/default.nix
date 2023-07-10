{
  nixpkgs.overlays = [
    (self: super: {
      gnome-console = super.gnome-console.overrideAttrs (
        { patches ? [ ], ... }: {
          patches = patches ++ [
            ./no-notification.patch
            ./no-warn-close.patch
            ./tango.patch
          ];
        }
      );
    })
  ];
}
