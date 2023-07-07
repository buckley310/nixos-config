nixosModule:

builtins.mapAttrs

  (name: system: {
    inherit system;
    modules = [
      nixosModule
      (./. + "/${name}")
      { networking.hostName = name; }
    ];
  })

{
  hp = "x86_64-linux";
  levi = "x86_64-linux";
  testbox = "x86_64-linux";
}
