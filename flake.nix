{
  outputs = { self, nixpkgs }: {
    nixosModule = { ... }: {
      imports = [ ./. ];
      config = { sconfig.flakes.enable = true; };
    };
  };
}
