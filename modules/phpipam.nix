{ config, pkgs, lib, ... }:
let
  cfg = config.sconfig.phpipam;

  version = "1.5.2";

  phpipamHtdocs = pkgs.stdenv.mkDerivation {
    inherit version;
    pname = "phpipam-htdocs";
    src = pkgs.fetchFromGitHub {
      owner = "phpipam";
      repo = "phpipam";
      rev = "v${version}";
      sha256 = "FeE6sF2IoXf5/z9PFn3w9l/fnsvkXwt3O6mY92clPjQ=";
      fetchSubmodules = true;
    };
    installPhase = ''
      cp -r "$src" "$out"
      chmod +w "$out"
      echo '<?php
            require("config.dist.php");
            $db["host"] = "localhost";
            $db["user"] = "nginx";
            require("/etc/phpipam_config.php");' >"$out/config.php"
    '';
  };

in
{
  options.sconfig.phpipam = {

    enable = lib.mkEnableOption "Enable phpipam";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to phpipam configuration file";
      default = null;
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
    };

    virtualHost = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };

    phpPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.php74.buildEnv {
        extraConfig = ''
          max_execution_time = 600
          date.timezone = ${config.time.timeZone}
        '';
      };
    };

  };

  config = lib.mkIf cfg.enable {

    environment.etc."phpipam_config.php" =
      if cfg.configFile == null
      then { text = ""; }
      else { source = cfg.configFile; };

    systemd = {
      services.phpipam-tasks = {
        script = ''
          ${cfg.phpPackage}/bin/php ${phpipamHtdocs}/functions/scripts/pingCheck.php
          ${cfg.phpPackage}/bin/php ${phpipamHtdocs}/functions/scripts/discoveryCheck.php
          ${cfg.phpPackage}/bin/php ${phpipamHtdocs}/functions/scripts/remove_offline_addresses.php
        '';
        serviceConfig.User = "nginx";
      };
      timers.phpipam-tasks = {
        timerConfig.OnBootSec = 600;
        timerConfig.OnUnitInactiveSec = 600;
        timerConfig.RandomizedDelaySec = 300;
        wantedBy = [ "timers.target" ];
      };
    };

    services = {
      phpfpm.phpPackage = cfg.phpPackage;
      phpfpm.pools.www = {
        user = "nginx";
        group = "nginx";
        phpEnv.PHP_INI_SCAN_DIR = "$PHP_INI_SCAN_DIR";
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
        virtualHosts."${cfg.hostname}" = lib.mkMerge [
          cfg.virtualHost
          {
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
              include        ${config.services.nginx.package}/conf/fastcgi.conf;
            '';
          }
        ];
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
