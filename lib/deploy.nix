{ self
, system ? "x86_64-linux"
, modules ? [ ]
}:

let
  inherit (self.inputs) nixpkgs;
  inherit (self) nixosConfigurations;

  helpers = system:
    let
      inherit (nixpkgs.lib) concatMapStrings;
      inherit (nixpkgs.legacyPackages.${system}) pkgs;

      sshKnownHostsTxt = pkgs.writeText "known_hosts" (concatMapStrings
        (hostName:
          let m = nixosConfigurations.${hostName}.config.sconfig;
          in concatMapStrings (key: "${m.deployment.targetHost} ${key}\n") m.sshPublicKeys
        )
        (builtins.attrNames nixosConfigurations)
      );

      hostSshConfigs = concatMapStrings
        (hostName: ''
          Host ${hostName}
          HostName ${nixosConfigurations.${hostName}.config.sconfig.deployment.targetHost}
        '')
        (builtins.attrNames nixosConfigurations);

      sshConfig = pkgs.writeText "ssh_config" ''
        StrictHostKeyChecking yes
        GlobalKnownHostsFile ${sshKnownHostsTxt}
        ${hostSshConfigs}
        Host *
        User root
      '';

      jump = pkgs.writeShellScript "jump" ''
        set -eu
        echo ${self}
        ip="$(nix eval --raw ".#nixosConfigurations.\"$1\".config.sconfig.deployment.targetHost")"
        NIX_SSHOPTS="-F${sshConfig}" nix copy --to ssh://root@$ip ${self}
        exec ssh -oForwardAgent=yes -F"${sshConfig}" "root@$ip" -t "cd ${self}; nix develop"
      '';

      livecd-deploy = pkgs.writeShellScript "livecd-deploy" ''
        set -eux
        config=".#nixosConfigurations.\"$1\".config"
        ip="$(nix eval --raw "$config.sconfig.deployment.targetHost")"
        ssh-copy-id root@$ip
        sys="$(nix eval --raw "$config.system.build.toplevel")"
        nix build "$config.system.build.toplevel" --out-link "$(mktemp -d)/result"
        nix copy --to ssh://root@$ip?remote-store=local?root=/mnt "$sys"
        ssh root@$ip nix-env --store /mnt -p /mnt/nix/var/nix/profiles/system --set "$sys"
        ssh root@$ip mkdir /mnt/etc
        ssh root@$ip touch /mnt/etc/NIXOS
        ssh root@$ip ln -sfn /proc/mounts /mnt/etc/mtab
        ssh root@$ip NIXOS_INSTALL_BOOTLOADER=1 nixos-enter \
            --root /mnt -- /run/current-system/bin/switch-to-configuration boot
      '';

      check-updates = pkgs.writeShellScript "check-updates" ''
        set -eu
        export SSH_CONFIG_FILE=${sshConfig}
        c="${pkgs.colmena}/bin/colmena"
        diff <(
          $c exec -v -- readlink /run/current-system |& grep /nix/store | sed 's/.*| //g' | sort
        ) <(
          $c eval -E '
            { nodes, ... }: map (x: x.config.system.build.toplevel) (builtins.attrValues nodes)
          ' | jq .[] -r | sort
        )
      '';

    in
    { inherit check-updates jump livecd-deploy pkgs sshConfig; };

in
{
  devShell = system: with helpers system;
    pkgs.mkShell {
      buildInputs = [ pkgs.colmena ];
      shellHook = ''
        export SSH_CONFIG_FILE=${sshConfig}
        alias ssh='ssh -F${sshConfig}'
        alias jump=${jump}
        alias check-updates=${check-updates}
        alias livecd-deploy=${livecd-deploy}
        alias c=colmena
      '';
    };


  colmena =
    { meta.nixpkgs = nixpkgs.legacyPackages.${system}; } //
    builtins.mapAttrs
      (name: value: {
        nixpkgs.system = value.config.nixpkgs.system; # needed for multi-arch deployments
        imports = value.extraArgs.modules ++ [
          ({ config, ... }: { inherit (config.sconfig) deployment; })
        ];
      })
      (nixosConfigurations);
}
