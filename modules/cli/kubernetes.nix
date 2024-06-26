{ pkgs, ... }:
{
  programs.bash.interactiveShellInit = ''
    source <(kubectl completion bash)
    complete -F __start_kubectl k
  '';
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    stern

    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

    # dedicated script, because bash aliases dont work with `watch`
    (writeShellScriptBin "k" "exec kubectl \"$@\"")
  ];
}
