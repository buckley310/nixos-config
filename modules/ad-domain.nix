{ config, lib, pkgs, ... }:

let
  cfg = config.sconfig.ad-domain;
in
{
  options.sconfig.ad-domain = with lib; with types;
    {
      enable = mkEnableOption "Join Domain with SSSD";
      longname = mkOption {
        type = str;
        example = "example.com";
      };
      shortname = mkOption {
        type = str;
        example = "EXAMPLE";
      };
    };

  config = lib.mkIf cfg.enable
    {
      networking.domain = cfg.longname;
      networking.search = [ (cfg.longname) ];
      security.pam.services.sshd.makeHomeDir = true;
      security.krb5 = {
        # These settings have been updated for NixOS 24.05.
        # Breaking changes happenned since 23.11.
        enable = true;
        settings.libdefaults.default_realm = lib.toUpper cfg.longname;
      };
      services.sssd = {
        enable = true;
        sshAuthorizedKeysIntegration = true;
        config = ''
          [sssd]
          services = nss, pam, ssh
          config_file_version = 2
          domains = ${cfg.longname}
          [domain/${cfg.longname}]
          id_provider = ad
          ldap_sasl_mech = gssapi
          access_provider = ad
          override_homedir = /home/%u.%d
          override_shell = /run/current-system/sw/bin/bash
          ad_gpo_access_control = permissive
          ad_gpo_ignore_unreadable = True
          ldap_user_extra_attrs = altSecurityIdentities:altSecurityIdentities
          ldap_user_ssh_public_key = altSecurityIdentities
          ldap_use_tokengroups = True
        '';
      };
      # Samba is configured, but just for the "net" command, to
      # join the domain. A better join method probably exists.
      # `net ads join -U Administrator`
      environment.systemPackages = [ pkgs.samba4Full ];
      systemd.services.samba-smbd.enable = lib.mkDefault false;
      services.samba = {
        enable = true;
        enableNmbd = lib.mkDefault false;
        enableWinbindd = lib.mkDefault false;
        package = pkgs.samba4Full;
        securityType = "ads";
        extraConfig = ''
          realm = ${lib.toUpper cfg.longname}
          workgroup = ${lib.toUpper cfg.shortname}
          client use spnego = yes
          restrict anonymous = 2
          server signing = mandatory
          client signing = mandatory
          kerberos method = secrets and keytab
        '';
      };
    };
}
