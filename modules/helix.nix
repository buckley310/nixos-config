{ pkgs, ... }:
let
  hx-pretty = {
    command = "prettier";
    args = [
      "--verify"
      "--stdin-filepath"
      "%{buffer_name}"
    ];
  };

  prettier-formats =
    map
      (name: {
        inherit name;
        auto-format = true;
        indent = {
          tab-width = 4;
          unit = "\t";
        };
        formatter = hx-pretty;
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
      scrolloff = 99;
      end-of-line-diagnostics = "hint";
      inline-diagnostics.cursor-line = "hint";
      soft-wrap.enable = true;
      file-picker.hidden = false;
    };
    keys = {
      normal.space.backspace = ":reset-diff-change";
      normal.pagedown = "page_cursor_half_down";
      normal.pageup = "page_cursor_half_up";
    };
  };

  environment.etc."bck-helix/languages.toml".source =
    (pkgs.formats.toml { }).generate "languages.toml"
      {
        language = prettier-formats ++ [
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
            formatter = hx-pretty;
          }
        ];
      };

  environment.systemPackages = [ pkgs.helix ];

  environment.etc."bck-settings.sh".text = ''
    mkdir -p ~/.config/helix
    ln -fs /etc/bck-helix/{config,languages}.toml ~/.config/helix/
  '';
}
