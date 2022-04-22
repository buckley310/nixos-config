{ config, pkgs, lib, ... }:
let

  cfg = config.sconfig.powerline;

  theme = pkgs.writeText "powerline.json" (builtins.toJSON
    {
      BoldForeground = true;
      CwdFg = 15;
      PathBg = 24;
      PathFg = 15;
      SeparatorFg = 16;
    });

in
{
  options.sconfig.powerline =
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "-modules=\${remote:+'user,host,'}nix-shell,shlvl,git,jobs,cwd"
          "-git-assume-unchanged-size 0"
          "-theme ${theme}"
          "-path-aliases '~/git=~/git'"
          "-jobs $(jobs -p | wc -l)"
        ] ++ config.sconfig.powerline.extraArgs;
      };
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      ((pkgs.callPackage
        (pkgs.fetchurl
          {
            url = "https://raw.githubusercontent.com/NixOS/nixpkgs/6ce4a720012398d451c21bc042d6740e92289615/pkgs/tools/misc/powerline-go/default.nix";
            sha256 = "7a8294ac9726da9531f1e506369233b051ecc6aa32c77a281f7167027a89977e";
          }
        )
        { }
      ).overrideAttrs (old: {
        patches = [
          ./shlvl.patch
        ];
      }))
    ];

    programs.bash.interactiveShellInit = ''
      function _update_ps1() {
        local remote=y
        [ "$XDG_SESSION_TYPE" = "x11" ] && unset remote
        [ "$XDG_SESSION_TYPE" = "wayland" ] && unset remote
        PS1="\n$(powerline-go ${lib.concatStringsSep " " cfg.args})"
      }
      [ "$TERM" = "linux" ] || PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    '';

  };
}
