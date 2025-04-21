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
      awscli2
      black
      cargo
      efm-langserver
      errcheck
      gh
      go
      gopls
      kubectl
      kubernetes-helm
      lua-language-server
      nil
      nix-prefetch-github
      nodePackages.prettier
      nodePackages.typescript-language-server
      pyright
      rust-analyzer
      rustc
      rustc.llvmPackages.lld
      rustfmt
      stern
      terraform
      terraform-ls
      vscode-langservers-extracted
      yaml-language-server

      # dedicated script, because bash aliases dont work with `watch`
      (writeShellScriptBin "k" "exec kubectl \"$@\"")
    ];
    programs.bash.interactiveShellInit = ''
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
