{
  nixpkgs.overlays = [

    # (final: prev: {
    #   brave = prev.callPackage "${prev.path}/pkgs/by-name/br/brave/make-brave.nix" { } rec {
    #     hash = "";
    #     version = "";
    #     pname = "brave";
    #     url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
    #   };
    # })

  ];
}
