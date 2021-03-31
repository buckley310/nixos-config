{
  outputs = { self, nixpkgs }: {
    nixosModule = import ./.;
  };
}
