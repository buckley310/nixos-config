{ self
, hosts
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
        c="${pkgs.colmena}/bin/colmena"
        j="$($c eval -E '{nodes,...}: builtins.mapAttrs (n: v: v.config.system.build.toplevel) nodes')"
        $c exec -- '[ "$(echo '"'$j'"' | jq -r .\"$(hostname)\")" = "$(readlink /run/current-system)" ]'
      '';

      check-reboots = pkgs.writeShellScript "check-reboots" ''
        set -eu
        c="${pkgs.colmena}/bin/colmena"
        $c exec -- '[ "$(readlink /run/booted-system/kernel)" = "$(readlink /run/current-system/kernel)" ]'
      '';

    in
    { inherit check-updates check-reboots livecd-deploy pkgs sshConfig; };

in
{
  defaultPackage = system: with helpers system;
    pkgs.writeShellScript "deploy-init" ''
      export SSH_CONFIG_FILE=${sshConfig}
      alias ssh='ssh -F${sshConfig}'
      alias check-updates=${check-updates}
      alias check-reboots=${check-reboots}
      alias livecd-deploy=${livecd-deploy}
      alias c=${pkgs.colmena}/bin/colmena
    '';

  colmena =
    # colmena evaluates in impure mode, so currentSystem is OK for now
    { meta.nixpkgs = nixpkgs.legacyPackages.${builtins.currentSystem}; } //
    builtins.mapAttrs
      (name: value: {
        imports = value.modules ++ [
          ({ config, ... }: { inherit (config.sconfig) deployment; })
        ];
      })
      (hosts);
}
