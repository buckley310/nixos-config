{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.phpipam;

  version = "1.4.3";

  phpipamHtdocs = pkgs.stdenv.mkDerivation {
    inherit version;
    pname = "phpipam-htdocs";
    src = pkgs.fetchFromGitHub {
      owner = "phpipam";
      repo = "phpipam";
      rev = "v${version}";
      sha256 = "lNwXBfjYDR7anFv/k3h+bqVayxbX3kI1Y3mcdrVWv/Q=";
      fetchSubmodules = true;
    };
    installPhase = ''
      cp -r "$src" "$out"
      chmod +w "$out"
      mv "$out/config.docker.php" "$out/config.php"
    '';
  };

  cronScripts = {
    phpipam_ping = "exec ${pkgs.php}/bin/php ${phpipamHtdocs}/functions/scripts/pingCheck.php";
    phpipam_remove_offline = "exec ${pkgs.php}/bin/php ${phpipamHtdocs}/functions/scripts/remove_offline_addresses.php";
    phpipam_discovery = "exec ${pkgs.php}/bin/php ${phpipamHtdocs}/functions/scripts/discoveryCheck.php";
  };

in
{
  options.sconfig.phpipam = {

    enable = lib.mkEnableOption "Enable phpipam";

    domainName = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
    };

    useTLS = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    certificatePath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/phpipam.crt";
    };

    certificateKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/phpipam.key";
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services = builtins.mapAttrs
      (_: script: {
        inherit script;
        environment.IPAM_DATABASE_USER = "nginx";
        serviceConfig.User = "nginx";
        startAt = "*:0/15";
      })
      cronScripts;

    systemd.timers = builtins.mapAttrs
      (_: _: { timerConfig.RandomizedDelaySec = 600; })
      cronScripts;

    services = {

      phpfpm.pools.www = {
        user = "nginx";
        group = "nginx";
        phpEnv.IPAM_DATABASE_USER = "nginx";
        phpEnv.PHP_INI_SCAN_DIR = "$PHP_INI_SCAN_DIR";
        phpOptions = ''
          date.timezone = America/New_York
          max_execution_time = 600
        '';
        settings = {
          "pm" = "ondemand";
          "pm.max_children" = "8";
          "listen.group" = "nginx";
          "php_admin_value[error_log]" = "stderr";
          "catch_workers_output" = "yes";
        };
      };

      nginx = {
        enable = true;
        virtualHosts."${cfg.domainName}" = {
          addSSL = cfg.useTLS;
          sslCertificate = cfg.certificatePath;
          sslCertificateKey = cfg.certificateKeyPath;
          extraConfig = "access_log syslog:server=unix:/dev/log;";
          root = phpipamHtdocs;
          locations."/".extraConfig = ''
            try_files $uri $uri/ /index.php; index index.php;
          '';
          locations."/api/".extraConfig = ''
            try_files $uri $uri/ /api/index.php;
          '';
          locations."~ \\.php$".extraConfig = ''
            fastcgi_pass   unix:${config.services.phpfpm.pools.www.socket};
            fastcgi_index  index.php;
            try_files      $uri $uri/ index.php = 404;
            include        ${pkgs.nginx}/conf/fastcgi.conf;
          '';
        };
      };

      mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ "phpipam" ];
        ensureUsers = [{ name = "nginx"; ensurePermissions = { "phpipam.*" = "ALL PRIVILEGES"; }; }];
      };

    };
  };
}
