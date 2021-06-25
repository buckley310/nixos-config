{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.unstable.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModules = {
        baseline = ./modules/baseline.nix;
        cli = ./modules/cli.nix;
        gnome = ./modules/gnome.nix;
        phpipam = ./modules/phpipam.nix;
        pipewire = ./modules/pipewire.nix;
        profiles = ./modules/profiles.nix;
        scansnap_s1300 = ./modules/scansnap_s1300.nix;
        scroll-boost = ./modules/scroll-boost;
        security-tools = ./modules/security-tools.nix;
        status-on-console = ./modules/status-on-console.nix;
        sway = ./modules/sway.nix;
      };

      nixosModule = { ... }: { imports = builtins.attrValues self.nixosModules; };

      nixosConfigurations = self.lib.getHosts inputs ./hosts;

      lib = {
        getHosts = import lib/hosts.nix;
        forAllSystems = f: builtins.listToAttrs (map
          (name: { inherit name; value = f name; })
          (nixpkgs.lib.platforms.all)
        );
      };

      packages = self.lib.forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        {
          binaryninja = callPackage ./pkgs/binary-ninja-personal { };
          commander-x16 = callPackage ./pkgs/commander-x16 { };
          gef = callPackage ./pkgs/gef { };
          packettracer = callPackage ./pkgs/packettracer { };
          weevely = callPackage ./pkgs/weevely { };
        }
      );

      apps = self.lib.forAllSystems (system:
        with nixpkgs.legacyPackages.${system};
        {
          format-luks = writeShellScriptBin "format-luks" ''
            set -e
            read -p "Path to new LUKS device: " blkdev
            set -x
            cryptsetup -y -v luksFormat "$blkdev"
            cryptsetup --allow-discards open "$blkdev" cryptroot
            mkfs.btrfs /dev/mapper/cryptroot
            mount /dev/mapper/cryptroot /mnt -o discard,compress=zstd
            btrfs subvolume create /mnt/os
            btrfs subvolume create /mnt/home
            umount /mnt
            mount /dev/mapper/cryptroot /mnt -o discard,compress=zstd,subvol=/os
            mkdir /mnt/home
            mount /dev/mapper/cryptroot /mnt/home -o discard,compress=zstd,subvol=/home
          '';
        }
      );
    };
}
