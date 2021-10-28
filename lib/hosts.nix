{ path, nixpkgs, nixosModule }:
let

  inherit (builtins) mapAttrs attrValues attrNames readDir foldl' listToAttrs;

  # grab a list of systems, with associated hostnames
  # { x86_64-linux = [ "host1" "host2" ]; }
  sysToHosts = mapAttrs
    (system: _: attrNames (readDir (path + "/${system}")))
    (readDir path);

  # invert the attrset, from {sys=[name]} to {name=sys}
  # { host1 = "x86_64-linux"; host2 = "x86_64-linux"; }
  hostToSys = foldl' (a: b: a // b) { }
    (attrValues
      (mapAttrs
        (system: hosts: listToAttrs (map (name: { inherit name; value = system; }) hosts))
        sysToHosts));

  # build system configurations
  # { host1 = <nixosConfiguration>; host2 = <nixosConfiguration>; }
  hostToConfig = mapAttrs
    (hostName: system: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        (nixosModule)
        (path + "/${system}/${hostName}")
        (_: { networking.hostName = hostName; })
      ];
    })
    hostToSys;

in
hostToConfig
