{ fetchFromGitHub
, linuxManualConfig
, linux_6_1
, kernel ? linux_6_1
}:

let
  fcsrc = fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = "firecracker";
    rev = "v1.7.0";
    hash = "sha256-NuVH12cy38uu+8oms66p9k0xoMOJSl5AvY5pD1FCKkI=";
  };

  shortVer = builtins.head (
    builtins.match
      "([0-9]+\.[0-9]+).*"
      kernel.version
  );

in
(linuxManualConfig {

  inherit (kernel) src version;
  configfile =
    "${fcsrc}/resources/guest_configs/microvm-kernel-ci-x86_64-${shortVer}.config";

}).overrideAttrs (o: {

  postInstall = (o.postInstall or "") + ''
    cp vmlinux $out/
  '';

})
