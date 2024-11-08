let

  brave = (
    final: prev: {
      brave =
        let
          # updates to the newer version before it hits the channels
          version = "1";
          hash = "";
        in
        if prev.lib.versionAtLeast prev.brave.version version then
          prev.brave
        else
          prev.brave.overrideAttrs {
            src = prev.fetchurl {
              inherit hash;
              url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
            };
          };
    }
  );

in
{
  nixpkgs.overlays = [
    brave
  ];
}
