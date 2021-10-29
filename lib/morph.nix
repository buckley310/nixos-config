{ nixpkgs
, nixosConfigurations
, path
, flake
, extraMorphModules ? [ ]
}:

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
          { inherit (value.config.sconfig.morph) deployment; }
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
          let m = nixosConfigurations.${hostName}.config.sconfig.morph;
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

      livecd-deploy = sh ''
        config=".#nixosConfigurations.\"$1\".config"
        nix build "$config.system.build.toplevel" --out-link "$(mktemp -d)/result"
        sys="$(nix eval --raw "$config.system.build.toplevel")"
        ip="$(nix eval --raw "$config.sconfig.morph.deployment.targetHost")"
        nix copy --to ssh://root@$ip?remote-store=local?root=/mnt "$sys"
        ssh root@$ip nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set "$sys"
        ssh root@$ip mkdir /mnt/etc
        ssh root@$ip touch /mnt/etc/NIXOS
        ssh root@$ip ln -sfn /proc/mounts /mnt/etc/mtab
        ssh root@$ip NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root /mnt -- /run/current-system/bin/switch-to-configuration boot
      '';

      push = sh ''
        exec "${morph}/bin/morph" push ${morph-config} "$@"
      '';

      ssh = sh ''
        ip="$(nix eval --raw --file ./. "nixosConfigurations.\"$1\".config.sconfig.morph.deployment.targetHost")"
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
