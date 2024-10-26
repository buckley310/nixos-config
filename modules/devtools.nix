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
        kubectl
        kubernetes-helm
        lua-language-server
        nil
        nodePackages.prettier
        nodePackages.typescript-language-server
        pyright
        rust-analyzer
        rustc
        rustc.llvmPackages.lld
        rustfmt
        stern
        vscode-langservers-extracted
        yaml-language-server

        # dedicated script, because bash aliases dont work with `watch`
        (writeShellScriptBin "k" "exec kubectl \"$@\"")

        (google-cloud-sdk.withExtraComponents
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      ];
    programs.bash.interactiveShellInit = ''
      source <(kubectl completion bash)
      complete -F __start_kubectl k
    '';
  };
}
