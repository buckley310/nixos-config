lib:
nixosConfigurations:

let
  sshKnownHostsTxt = builtins.toFile "known_hosts" (lib.concatMapStrings
    (hostName:
      let d = nixosConfigurations.${hostName}.config.deploy;
      in lib.concatMapStrings (key: "${d.targetHost} ${key}\n") d.sshPublicKeys
    )
    (builtins.attrNames nixosConfigurations)
  );

in
builtins.toFile "ssh-config" (''
  StrictHostKeyChecking yes
  GlobalKnownHostsFile ${sshKnownHostsTxt}
'' +
lib.concatMapStrings
  (host: ''
    Host ${host}
    HostName ${nixosConfigurations.${host}.config.deploy.targetHost}
  '')
  (builtins.attrNames nixosConfigurations))
