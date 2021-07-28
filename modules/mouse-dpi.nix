{ lib, ... }:
let
  dpi = {
    "SteelSeries SteelSeries Aerox 3 Wireless" = "600@1000";
    "Logitech G Pro Gaming Mouse" = "600@1000";
    "Logitech G305" = "600@1000";
    "Glorious Model O" = "600@1000";
  };
in
{
  services.udev.extraHwdb = lib.concatMapStrings
    (n: "\nmouse:usb:*:name:${n}:*\n MOUSE_DPI=${dpi.${n}}\n")
    (builtins.attrNames dpi);
}
