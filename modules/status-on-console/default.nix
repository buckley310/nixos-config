{ config, pkgs, ... }:
let
  ncfg = pkgs.writeText "neofetch.conf" ''
    print_info() {
        info title
        info underline

        info "OS" distro
        info "Host" model
        info "Kernel" kernel
        info "Uptime" uptime
        info "Packages" packages
        info "Shell" shell
        info "Resolution" resolution
        info "CPU" cpu
        info "Memory" memory
        info "Disk" disk
        info "Local IP" local_ip
        # info "Public IP" public_ip
        info "Users" users

        info cols
    }
  '';

  nscript = pkgs.writeShellScript "neofetch-wrapped" ''
    export PATH="$PATH:/run/current-system/sw/bin"
    (
      ${pkgs.neofetch}/bin/neofetch --config "${ncfg}"
      echo '\l'
    ) >/run/issue
  '';

in
{
  environment.etc.issue.source = pkgs.lib.mkForce "/run/issue";
  systemd.services."getty@".serviceConfig.ExecStartPre = "-${nscript}";
}
