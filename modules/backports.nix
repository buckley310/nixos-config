{ pkgs, ... }:
{
  nixpkgs.overlays = [

    (self: super: {
      powerline-go = pkgs.callPackage
        (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixpkgs/31106c85cb1dc50755f9dd41244575332b6b64c2/pkgs/tools/misc/powerline-go/default.nix";
          sha256 = "1ikm7s0g00bkfagc5f2fwlgc050cb6p4pprdg3f6s8j4ri927970";
        })
        { };
    })

    (self: super: {
      brave = super.brave.overrideAttrs (b: rec {
        version = "1.18.75";
        src = pkgs.fetchurl {
          url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
          sha256 = "1njgdw7ml30xs517brc7z7piy6lcylrfjhz6wn1dp7gywsxfgx1h";
        };
      });
    })

  ];
}
