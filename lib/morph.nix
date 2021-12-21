{ self
, extraMorphModules ? [ ]
}:

# to use this library, add the following to "morph.nix" in your repo:
# (builtins.getFlake (toString ./.)).morph-entrypoint builtins.currentSystem

let
  inherit (self.inputs) nixpkgs;
  inherit (self) nixosConfigurations;

  helpers = system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs.lib) concatMapStrings;

      sshKnownHostsTxt = pkgs.writeText "known_hosts" (concatMapStrings
        (hostName:
          let m = nixosConfigurations.${hostName}.config.sconfig.morph;
          in concatMapStrings (key: "${m.deployment.targetHost} ${key}\n") m.sshPublicKeys
        )
        (builtins.attrNames nixosConfigurations)
      );

      hostSshConfigs = concatMapStrings
        (hostName: ''
          Host ${hostName}
          User root
          HostName ${nixosConfigurations.${hostName}.config.sconfig.morph.deployment.targetHost}
        '')
        (builtins.attrNames nixosConfigurations);

      sshConfig = pkgs.writeText "ssh_config" ''
        StrictHostKeyChecking yes
        GlobalKnownHostsFile ${sshKnownHostsTxt}
        ${hostSshConfigs}
      '';

      sh = scriptBody: pkgs.writeShellScriptBin "run" ''
        set -eu
        export SSH_CONFIG_FILE=${sshConfig}
        ${scriptBody}
      '';

      jump = pkgs.writeShellScript "jump" ''
        set -eu
        echo ${self}
        ip="$(nix eval --raw ".#nixosConfigurations.\"$1\".config.sconfig.morph.deployment.targetHost")"
        NIX_SSHOPTS="-F${sshConfig}" nix copy --to ssh://root@$ip ${self}
        exec ssh -oForwardAgent=yes -F"${sshConfig}" "root@$ip" -t "cd ${self}; nix develop"
      '';

    in
    { inherit jump pkgs sh sshConfig; };

in
{
  devShell = system: with helpers system;
    pkgs.mkShell {
      buildInputs = [ pkgs.morph ];
      shellHook = ''
        export SSH_CONFIG_FILE=${sshConfig}
        alias ssh='ssh -F${sshConfig}'
        alias jump=${jump}
      '';
    };


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


  packages = system: with helpers system;
    {
      check-updates = sh ''
        res="$(morph build morph.nix)"
        diff \
            <(find $res -type l | xargs readlink | sort) \
            <(morph exec morph.nix 'readlink /run/current-system' |& grep '^/nix/store/' | sort)
      '';
      livecd-deploy = sh ''
        config=".#nixosConfigurations.\"$1\".config"
        ip="$(nix eval --raw "$config.sconfig.morph.deployment.targetHost")"
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
    };
}
