nixpkgs: hardware: nixosModule:
with hardware;

builtins.mapAttrs

  (name: { system, mods }: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = mods ++ [
      nixosModule
      { networking.hostName = name; }
    ];
  })

{
  cube = { system = "x86_64-linux"; mods = [ physical ./cube ]; };
  hp = { system = "x86_64-linux"; mods = [ physical ./hp ]; };
  lenny = { system = "x86_64-linux"; mods = [ physical ./lenny ]; };
  nixdev = { system = "x86_64-linux"; mods = [ qemu ./nixdev ]; };
  slate = { system = "x86_64-linux"; mods = [ physical ./slate ]; };
}
