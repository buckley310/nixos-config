{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.devtools;
in
{
  options.sconfig.devtools.enable = lib.mkEnableOption "Development Tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        black
        cargo
        efm-langserver
        errcheck
        go
        gopls
        lua-language-server
        nil
        nodePackages.prettier
        nodePackages.typescript-language-server
        pyright
        rust-analyzer
        rustc
        rustc.llvmPackages.lld
        rustfmt
        vscode-langservers-extracted
        yaml-language-server
      ];
  };
}
