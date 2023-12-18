{ fetchFromGitHub
, linuxManualConfig
, linux_6_1
, kernel ? linux_6_1
}:

let
  fcsrc = fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = "firecracker";
    rev = "e1c351bdde745d33858e04089eef6e2279b286fd";
    hash = "sha256-LvVqA5jBKWQYeV9OHrrb+1gmAqHxDszeVBhFwweDrmo=";
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
