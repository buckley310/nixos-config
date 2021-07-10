{ lib, ... }:
let
  dpi = {
    "Logitech USB Receiver" = "800@1000";
    "Logitech G Pro Gaming Mouse" = "800@1000";
    "Logitech G305" = "800@1000";
  };
in
{
  services.udev.extraHwdb = lib.concatMapStrings
    (n: "\nmouse:usb:*:name:${n}:*\n MOUSE_DPI=${dpi.${n}}\n")
    (builtins.attrNames dpi);
}
