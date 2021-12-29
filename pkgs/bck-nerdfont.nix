{ stdenv
, lib
, dejavu_fonts
, fetchFromGitHub
, python3
, writeScript
}:

let
  py = python3.withPackages (p: [ p.fontforge ]);

  # Stick a rectangle on the left edge of the
  # powerline symbol to avoid anti-aliasing artifacts
  postprocess = writeScript "postprocess.py" ''
    #!${py}/bin/python
    import fontforge, psMat, sys, os
    f = fontforge.open(sys.argv[1])
    glyph = f[0xE0B0]
    bb = glyph.boundingBox()
    pen = glyph.glyphPen(replace=False)
    pen.moveTo(bb[0],bb[1])
    pen.lineTo(bb[0],bb[3])
    pen.lineTo(bb[0]-150,bb[3])
    pen.lineTo(bb[0]-150,bb[1])
    pen.closePath()
    os.unlink(sys.argv[1])
    f.generate(sys.argv[1])
  '';

in
stdenv.mkDerivation {
  name = "bck-nerdfont";

  dontUnpack = true;

  src = fetchFromGitHub {
    owner = "ryanoasis";
    repo = "nerd-fonts";
    rev = "v2.1.0";
    sha256 = "j0cLZHOLyoItdvLOQVQVurY3ARtndv0FZTynaYJPR9E=";
  };

  buildPhase = ''
    # Either Octicons or FontAwesome are required. Take your pick.
    # They cause the fontlinux characters to move to the correct slots.
    # (see fontlinuxExactEncodingPosition)
    find ${dejavu_fonts}/share/fonts/truetype -name 'DejaVuSansMono*' -print0 |
      xargs -0n1 ${py}/bin/python $src/font-patcher \
        --fontlinux --octicons --powerline \
        --postprocess ${postprocess}
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -v *.ttf $out/share/fonts/truetype/
  '';
}
