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
      scrolloff = 99;
      end-of-line-diagnostics = "hint";
      inline-diagnostics.cursor-line = "error";
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
    mkdir -p ~/.config/helix
    ln -fs /etc/bck-helix/{config,languages}.toml ~/.config/helix/
  '';
}
