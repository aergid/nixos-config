{pkgs, lib, ...}:
let
  fromGitHub = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
in
{
  imports = [
#    ./autocommands.nix
#    ./completion.nix
#    ./keymappings.nix
#    ./options.nix
#   ./plugins
#    ./todo.nix
  ];

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;


    # Highlight and remove extra white spaces
#    highlight.ExtraWhitespace.bg = "red";
#    match.ExtraWhitespace = "\\s\\+$";

    plugins = let
      nvim-treesitter-with-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter-plugins:
        with treesitter-plugins; [
          bash
          c
          cpp
          lua
          nix
          python
	  scala
	  java
        ]);
    in
      with pkgs.vimPlugins; [
        nvim-treesitter-with-plugins
	nvim-comment
	neoterm
#harpoon.nix
	lualine-nvim
	neo-tree-nvim
	vim-startify
	tagbar
	telescope-nvim
	vimtex
      #(fromGitHub "HEAD" "elihunter173/dirbuf.nvim")
      ];

  };
}
