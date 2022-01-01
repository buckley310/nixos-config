{ nerdfonts
, python3
, runCommand
, writeScript
}:

let
  py = python3.withPackages (p: [ p.fontforge ]);

  src = nerdfonts.override { fonts = [ "DejaVuSansMono" ]; };

  # Stick a rectangle on the left edge of the
  # powerline symbol to avoid anti-aliasing artifacts
  postprocess = writeScript "postprocess.py" ''
    #!${py}/bin/python
    import fontforge, psMat, sys, os
    f = fontforge.open(sys.argv[1])
    glyph = f[0xE0B0]
    bb = glyph.boundingBox()
    pen = glyph.glyphPen(replace=False)
    pen.moveTo(0, bb[1])
    pen.lineTo(0, bb[3])
    pen.lineTo(-150, bb[3])
    pen.lineTo(-150, bb[1])
    pen.closePath()
    os.unlink(sys.argv[1])
    f.generate(sys.argv[1])
  '';

in
runCommand "bck-nerdfont" { inherit src; } ''
  find $src -name '*Complete.ttf' -exec install -D -t $out/share/fonts/truetype {} \;
  find $out -name '*Complete.ttf' -exec ${postprocess} {} \;
''
