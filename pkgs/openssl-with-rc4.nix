{ callPackage, openssl_1_1, path, stdenv }:

# This package exists for testing.
# ./result-bin/bin/openssl ciphers -v "ALL:@SECLEVEL=0" | grep RC4

let

  oldScript = openssl_1_1.configureScript;

  edited = stdenv.mkDerivation {
    name = "openssl-with-rc4";
    src = path + "/pkgs/development/libraries/openssl";
    installPhase = ''
      sed -i 's|${oldScript}|${oldScript} enable-weak-ssl-ciphers|g' default.nix
      cp -a . $out
    '';
  };

in
(callPackage edited { }).openssl_1_1
