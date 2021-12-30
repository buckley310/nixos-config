{
  # $ xrandr --verbose
  # DisplayPort-0 connected primary 2560x1440+0+0 (0x5b) normal (normal left inverted right x axis y axis) 697mm x 392mm
  # 2560x1440 (0x5b) 646.280MHz +HSync -VSync *current
  # h: width  2560 start 2608 end 2640 total 2692 skew    0 clock 240.07KHz
  # v: height 1440 start 1443 end 1448 total 1455           clock 165.00Hz
  # DisplayPort-1 connected 2560x1440+2560+0 (0x7f) normal (normal left inverted right x axis y axis) 697mm x 392mm
  # 2560x1440 (0x7f) 650.030MHz +HSync -VSync *current
  # h: width  2560 start 2608 end 2640 total 2680 skew    0 clock 242.55KHz
  # v: height 1440 start 1443 end 1448 total 1470           clock 165.00Hz

  services.xserver.extraConfig = ''
    Section "Monitor"
      Identifier      "DisplayPort-0"
      Modeline        "2560x1440_165.00" 664.0  2560 2608 2640 2700  1440 1443 1448 1490  +HSync +VSync
      Option          "PreferredMode" "2560x1440_165.00"
    EndSection
    Section "Monitor"
      Identifier      "DisplayPort-1"
      Modeline        "2560x1440_165.00" 664.0  2560 2608 2640 2700  1440 1443 1448 1490  +HSync +VSync
      Option          "PreferredMode" "2560x1440_165.00"
    EndSection
  '';
}
