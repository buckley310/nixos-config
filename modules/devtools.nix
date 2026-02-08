{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.sconfig.devtools;
in
{
  options.sconfig.devtools.enable = lib.mkEnableOption "Development Tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

      # LSP / Formatter
      black
      nil
      vscode-langservers-extracted
      yaml-language-server
      python3.pkgs.python-lsp-server
      nodejs_24.pkgs.prettier
      nodejs_24.pkgs.typescript-language-server

      # Rust
      cargo
      rust-analyzer
      rustc
      rustc.llvmPackages.lld
      rustfmt

      # TF
      terraform
      terraform-ls

      # K8s
      kubectl
      kubernetes-helm
      stern
      (writeShellScriptBin "k" ''
        exec kubectl "$@"
      '')

      # Other
      caddy
      cloc
      gcc
      gh
      goaccess
      nix-prefetch-github
      nodejs_24
      # (google-cloud-sdk.withExtraComponents [
      #   google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    ];

    programs.bash.interactiveShellInit = ''
      alias t=terraform
      complete -C terraform t
      source <(kubectl completion bash)
      complete -F __start_kubectl k
    '';

    programs.git.enable = true;
  };
}
