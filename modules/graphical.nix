{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    firefox
    brave
    gimp
    mpv
    libreoffice
    tdesktop
    pavucontrol
    gnome3.dconf-editor
    glxinfo
    steam-run
    discord

    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        bbenoist.Nix
        ms-python.python
        ms-vscode.cpptools
        ms-azuretools.vscode-docker
      ];
    })

  ];

  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  programs.steam.enable = true;

  hardware.pulseaudio.enable = true;

  boot.loader.timeout = null;
}
