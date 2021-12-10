nixpkgs: hardware: nixosModule:
with hardware;

let
  sys = args: nixpkgs.lib.nixosSystem {
    system = builtins.head args;
    modules = [ nixosModule ] ++ builtins.tail args;
  };

in
{
  cube = sys [ "x86_64-linux" physical ./x86_64-linux/cube ];
  hp = sys [ "x86_64-linux" physical ./x86_64-linux/hp ];
  lenny = sys [ "x86_64-linux" physical ./x86_64-linux/lenny ];
  nixdev = sys [ "x86_64-linux" qemu ./x86_64-linux/nixdev ];
  slate = sys [ "x86_64-linux" physical ./x86_64-linux/slate ];
}
