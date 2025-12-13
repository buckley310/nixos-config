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
      efm-langserver
      nil
      lua-language-server
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
      cloc
      gh
      nix-prefetch-github
      nodejs_24
      # (google-cloud-sdk.withExtraComponents [
      #   google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    ];

    programs.bash.interactiveShellInit = ''
      alias cdk="npx aws-cdk"
      alias t=terraform
      complete -C terraform t
      source <(kubectl completion bash)
      complete -F __start_kubectl k
    '';

    programs.git = {
      enable = true;
      config = {
        alias.up = "push";
        alias.dn = "pull";
        alias.sh = "show";
        alias.glog = "log --all --decorate --oneline --graph";
        alias.glogl = "log --all --decorate --oneline --graph -n10";
        alias.logl = "log --oneline -n10";
        alias.vlog = "log --name-status";
        alias.diffc = "diff --cached";
        alias.st = "status";
        core.autocrlf = "input";
        core.pager = "less -x1,5";
        pull.ff = "only";
        init.defaultBranch = "main";
        "credential \"https://github.com\"".helper = [
          ""
          "!gh auth git-credential"
        ];
        "credential \"https://gist.github.com\"".helper = [
          ""
          "!gh auth git-credential"
        ];
      };
    };
  };
}
