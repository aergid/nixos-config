{pkgs, ...}:
{
  imports = [
    ./barbar.nix
    ./comment.nix
    ./floaterm.nix
    ./harpoon.nix
    ./indent-blankline.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown-preview.nix
    ./neo-tree.nix
    ./neorg.nix
    ./startify.nix
    ./tagbar.nix
    ./telescope.nix
    ./treesitter.nix
    ./zen-mode.nix
  ];

  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };


    plugins = {
      leap.enable = true;
      # web-devicons.enable = true;
      mini = {
        enable = true;
        mockDevIcons = true;
        modules.icons = { };
      };

      vim-surround.enable = true;

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
          };
        };
      };

      nvim-autopairs.enable = true;

      nvim-colorizer = {
        enable = true;
        userDefaultOptions.names = false;
      };

      oil.enable = true;
    };

    extraPlugins =
      # For plugins already packaged as nixpkgs
      with pkgs.vimPlugins; [
      ];
  };
}
