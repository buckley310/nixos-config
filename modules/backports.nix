[

  (self: super: {
    powerline-go = super.callPackage
      (super.fetchurl {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/31106c85cb1dc50755f9dd41244575332b6b64c2/pkgs/tools/misc/powerline-go/default.nix";
        sha256 = "1ikm7s0g00bkfagc5f2fwlgc050cb6p4pprdg3f6s8j4ri927970";
      })
      { };
  })

]
