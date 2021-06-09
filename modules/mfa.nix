{ pkgs, ... }:
let
  pkcslib = "${pkgs.opensc}/lib/opensc-pkcs11.so";
in
{
  services.pcscd.enable = true;
  programs.ssh.startAgent = true;
  programs.ssh.agentPKCS11Whitelist = pkcslib;
  environment.systemPackages = [
    pkgs.opensc
    (pkgs.writeShellScriptBin "mfa" "exec ssh-add -s${pkcslib}")
  ];

  nixpkgs.overlays = [
    (self: super: {
      gnome = super.gnome // {
        gnome-keyring = super.gnome.gnome-keyring.overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [ "--disable-ssh-agent" ];
        });
      };
    })
  ];

}
