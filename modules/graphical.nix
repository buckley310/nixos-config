{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    firefox
    brave
    gimp
    mpv
    libreoffice
    tdesktop
    steam
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

  # environment.systemPackages = with pkgs; [ retroarch ];
  # nixpkgs.config.retroarch = {
  #     enableParallelN64 = true;
  #     enableNestopia = true;
  #     enableHiganSFC = true;
  # };

  services.xserver.deviceSection = ''
    Option "VariableRefresh" "true"
  '';

  hardware = {
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    opengl.driSupport32Bit = true;
  };

  boot.loader.timeout = null;
}
