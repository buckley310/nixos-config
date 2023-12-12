{ pkgs, ... }:
{
  environment.variables.EDITOR = "vim";

  environment.systemPackages = with pkgs; [
    nodePackages.prettier

    (lunarvim.override (_: {
      viAlias = true;
      vimAlias = true;
      globalConfig = builtins.readFile ./init.lua + ''
        vim.cmd('source ${pkgs.vimPlugins.vim-tmux-navigator}/plugin/tmux_navigator.vim')
      '';
    }))

    (writeShellScriptBin "black" ''
      exec ${pkgs.python3.pkgs.black}/bin/black "$@"
    '')
  ];
}
