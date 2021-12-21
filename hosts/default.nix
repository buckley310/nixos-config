nixpkgs: hardware: nixosModule:
with hardware;

let
  sys = system: mods: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [ nixosModule ] ++ mods;
  };

in
{
  cube = sys "x86_64-linux" [ physical ./cube ];
  hp = sys "x86_64-linux" [ physical ./hp ];
  lenny = sys "x86_64-linux" [ physical ./lenny ];
  nixdev = sys "x86_64-linux" [ qemu ./nixdev ];
  slate = sys "x86_64-linux" [ physical ./slate ];
}
