{ lib
, writeTextDir
}:

writeTextDir "authorized_keys" (lib.concatLines (import ../lib/ssh-keys.nix))
