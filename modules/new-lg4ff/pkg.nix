{ stdenv, lib, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation {
  name = "new-lg4ff-${kernel.version}";

  src = fetchFromGitHub {
    owner = "berarma";
    repo = "new-lg4ff";
    # Rev with G923 support
    rev = "faeb74fecb0e8ce631758ac1df3f9a341a4d5eed";
    sha256 = "sha256-uXdV7KZeQGyA2u1WfC3V3pG3ZbVff3gIdTaPfCXrtm4=";
  };

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
  '';

  installPhase = ''
    export INSTALL_MOD_PATH="$out"
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules_install
  '';

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
}
