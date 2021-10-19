{ nixpkgs
, nixosConfigurations
, path
, flake
, extraMorphModules ? [ ]
}:

let

  allHostsMeta = builtins.mapAttrs
    (n: v: import (path + "/${n}"))
    nixosConfigurations;

in
{
  morph-entrypoint = system:
    let
      globalHealthChecks.cmd = [
        {
          cmd = [ "nixos-check-reboot" ];
          description = "Check for pending reboot";
        }
        {
          cmd = [ "systemctl is-system-running" ];
          description = "Check services are running";
        }
      ];

      getConfig = name: value: { ... }: {
        imports = extraMorphModules ++ nixosConfigurations.${name}.extraArgs.modules;
        config = nixpkgs.lib.mkMerge [
          { inherit (allHostsMeta.${name}) deployment; }
          { deployment.healthChecks = globalHealthChecks; }
        ];
      };

    in
    { network.pkgs = nixpkgs.legacyPackages.${system}; } //
    builtins.mapAttrs getConfig nixosConfigurations;



  packages = system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs.lib) concatMapStrings;

      sh = (scriptBody: pkgs.writeShellScriptBin "run" ''
        set -e
        die() { echo "$*" 1>&2 ; exit 1; }
        ${scriptBody}
      '');

      sshKnownHostsTxt = pkgs.writeText "known_hosts" (concatMapStrings
        (hostName:
          let m = allHostsMeta.${hostName};
          in concatMapStrings (key: "${m.deployment.targetHost} ${key}\n") m.sshPublicKeys
        )
        (builtins.attrNames nixosConfigurations)
      );

      sshConfig = pkgs.writeText "ssh_config" ''
        Host *
            User root
        ServerAliveInterval 3
        StrictHostKeyChecking yes
        GlobalKnownHostsFile ${sshKnownHostsTxt}
      '';

    in
    rec {

      morph-config = nixpkgs.legacyPackages.${system}.writeText "morph.nix" ''
        let  flake = builtins.getFlake "${flake}";
        in   flake.morph-entrypoint builtins.currentSystem
      '';

      morph = pkgs.runCommand "morph" { } ''
        mkdir -p $out/bin
        . ${pkgs.makeWrapper}/nix-support/setup-hook
        makeWrapper ${pkgs.morph}/bin/morph $out/bin/morph \
            --set SSH_CONFIG_FILE ${sshConfig}
      '';

      deploy = sh ''
        exec "${morph}/bin/morph" deploy ${morph-config} "$@"
      '';

      push = sh ''
        exec "${morph}/bin/morph" push ${morph-config} "$@"
      '';

      ssh = sh ''
        [ -n "$1" ] || die "Specify a host"
        [ -d "${path}/$1" ] || die "Invalid host"
        ip="$(nix eval --raw --file "${path}/$1" deployment.targetHost)"
        shift
        exec ssh -F"${sshConfig}" "$ip" "$@"
      '';

      check = sh ''
        res="$( ${morph}/bin/morph build ${morph-config} )"
        ${morph}/bin/morph check-health ${morph-config}
        echo -e "\nUpdate checks:"
        for hostname in $( ls "$res" ); do
            echo "  $hostname"
            diff \
                <('${ssh}/bin/run' "$hostname" readlink /run/current-system) \
                <(readlink "$res/$hostname") || true
        done
      '';
    };
}
