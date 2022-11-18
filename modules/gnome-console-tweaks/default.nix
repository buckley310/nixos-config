{
  nixpkgs.overlays = [
    (self: super: {
      gnome-console = super.gnome-console.overrideAttrs (prev: {
        patches = prev.patches ++ [
          ./background.patch
          ./no-close-tab-prompt.patch
          ./tango.patch
        ];
      });
    })
  ];
}
