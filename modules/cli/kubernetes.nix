{ config, pkgs, lib, ... }:
{
  programs.bash.interactiveShellInit = ''
    kc(){
      export KUBECONFIG=~/.kube/config."$1"
      kubectl get nodes
    }
    _kc_completion(){
      [ "''${#COMP_WORDS[@]}" != "2" ] ||
      COMPREPLY=($(compgen -W "$(ls ~/.kube/ | grep '^config\.' | sed 's/^config\.//g')" -- "''${COMP_WORDS[1]}"))
    }
    complete -F _kc_completion kc
    source <(kubectl completion bash)
    complete -F __start_kubectl k
    alias k=kubectl
  '';
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm

    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

  ];
}
