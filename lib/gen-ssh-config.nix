lib: nixosConfigurations:

let
  sshKnownHostsTxt = builtins.toFile "known_hosts" (
    lib.concatMapStrings (
      hostName:
      let
        d = nixosConfigurations.${hostName}.config.deploy;
      in
      lib.concatMapStrings (key: "${d.ssh.HostName} ${key}\n") d.sshPublicKeys
    ) (builtins.attrNames nixosConfigurations)
  );

  attrsToList = lib.mapAttrsToList (n: v: "${n} ${v}");
  attrsToLines = a: lib.concatLines (attrsToList a);

in
lib.concatMapStrings (host: ''
  Host ${host}
  UserKnownHostsFile ${sshKnownHostsTxt}
  ${attrsToLines nixosConfigurations.${host}.config.deploy.ssh}
'') (builtins.attrNames nixosConfigurations)
