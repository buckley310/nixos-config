{ pkgs, ... }:
let
  hx-pretty = pkgs.writeShellScript "hx-pretty.sh" ''
    exec prettier --stdin-filepath "$HX_FILE"
  '';

  prettier-formats =
    map
      (name: {
        inherit name;
        auto-format = true;
        indent = {
          tab-width = 4;
          unit = "\t";
        };
        formatter.command = hx-pretty;
      })
      [
        "css"
        "html"
        "javascript"
        "json"
        "jsonc"
        "typescript"
      ];

in
{
  environment.etc."bck-helix/config.toml".source = (pkgs.formats.toml { }).generate "config.toml" {
    theme = "dark_plus";
    editor = {
      auto-format = true;
      bufferline = "multiple";
      indent-guides.render = true;
      line-number = "relative";
      mouse = false;
      true-color = true;
      end-of-line-diagnostics = "hint";
      inline-diagnostics.cursor-line = "error";
      soft-wrap.enable = true;
    };
    keys = {
      normal.A-j = ":buffer-previous";
      normal.A-k = ":buffer-next";
      normal.space.e = ":w";
      normal.space.x = ":q";
      normal.space.backspace = ":reset-diff-change";
    };
  };

  environment.etc."bck-helix/languages.toml".source =
    (pkgs.formats.toml { }).generate "languages.toml"
      {
        language = prettier-formats ++ [
          {
            name = "bash";
            auto-format = true;
            indent = {
              tab-width = 4;
              unit = "\t";
            };
          }
          {
            name = "lua";
            auto-format = true;
            indent = {
              tab-width = 4;
              unit = "\t";
            };
          }
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "nixfmt";
              args = [ "--verify" ];
            };
          }
          {
            name = "python";
            auto-format = true;
            language-servers = [ "pyright" ];
            formatter = {
              command = "black";
              args = [
                "--quiet"
                "-"
              ];
            };
          }
          {
            name = "yaml";
            auto-format = true;
            formatter.command = hx-pretty;
          }
        ];
        language-server = {
          pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
          };
        };
      };

  environment.systemPackages = with pkgs; [
    (helix.overrideAttrs (
      {
        patches ? [ ],
        ...
      }:
      {
        # Patch required for .editorconfig to work properly with formatters
        patches = patches ++ [ ./format-filepath.patch ];
        postPatch = ''
          sed 's/tab-width = .,/tab-width = 4,/' -i languages.toml
        '';
      }
    ))
  ];

  environment.etc."bck-settings.sh".text = ''
    mkdir -p ~/.config && ln -nTfs /etc/bck-helix ~/.config/helix
  '';
}
