{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with pkgs.vscode-extensions; [
        esbenp.prettier-vscode
        jnoortheen.nix-ide
        ms-azuretools.vscode-docker
        ms-python.python
        redhat.vscode-yaml
        shardulm94.trailing-spaces
      ];
    })
  ];

  environment.etc."bck-settings.sh".text = ''
    mkdir -p ~/.config/Code/User
    ln -sf /etc/vscode-settings.json ~/.config/Code/User/settings.json
    ln -sf /etc/vscode-keybindings.json ~/.config/Code/User/keybindings.json
  '';

  environment.etc."vscode-keybindings.json".source = ./vscode-keybindings.json;
  environment.etc."vscode-settings.json".text = builtins.toJSON (
    (
      builtins.fromJSON (builtins.readFile ./vscode-settings.json)
    ) // {
      # NixOS-specific vscode settings:
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "terminal.external.linuxExec" = "x-terminal-emulator";
      "terminal.integrated.fontFamily" = "DejaVuSansM Nerd Font";
      "update.mode" = "none";
    }
  );
}
