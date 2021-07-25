{ lib, ... }:
let
  dpi = {
    "SteelSeries SteelSeries Aerox 3 Wireless" = "800@1000";
    "Logitech G Pro Gaming Mouse" = "800@1000";
    "Logitech G305" = "800@1000";
  };
in
{
  services.udev.extraHwdb = lib.concatMapStrings
    (n: "\nmouse:usb:*:name:${n}:*\n MOUSE_DPI=${dpi.${n}}\n")
    (builtins.attrNames dpi);
}
