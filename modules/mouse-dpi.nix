{ lib, ... }:
let
  setting = "600@1000";
  devices = [
    "SteelSeries SteelSeries Aerox 3 Wireless"
    "Logitech G Pro Gaming Mouse"
    "Logitech G305"
    "Glorious Model O"
  ];
in
{
  services.udev.extraHwdb = lib.concatMapStrings
    (n: "\nmouse:usb:*:name:${n}:*\n MOUSE_DPI=${setting}\n")
    (devices);
}
