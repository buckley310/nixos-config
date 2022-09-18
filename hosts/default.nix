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
  cube = "x86_64-linux";
  hp = "x86_64-linux";
  lenny = "x86_64-linux";
}
