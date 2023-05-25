{
  nixpkgs.overlays = [
    (self: super: {
      gnome-console = super.gnome-console.overrideAttrs (prev: {
        patches =
          (
            if (builtins.elem "patches" (builtins.attrNames prev))
            then prev.patches
            else [ ]
          ) ++ [
            ./no-notification.patch
            ./no-warn-close.patch
            ./tango.patch
          ];
      });
    })
  ];
}
