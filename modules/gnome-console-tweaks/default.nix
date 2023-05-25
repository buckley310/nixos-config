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
            ./no-close-tab-prompt.patch
            ./no-notification.patch
            ./tango.patch
          ];
      });
    })
  ];
}
