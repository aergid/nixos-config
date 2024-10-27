{pkgs, ...}:
{
  imports = [
    ./barbar.nix
    ./comment.nix
    ./floaterm.nix
    ./gitsigns.nix
    ./harpoon.nix
    ./indent-blankline.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown-preview.nix
    ./neo-tree.nix
    ./neorg.nix
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
      web-devicons.enable = true;
      which-key.enable = true;
      # mini = {
      #   enable = true;
      #   mockDevIcons = true;
      #   modules.icons = { };
      # };

      vim-surround.enable = true;

      alpha = {
        enable = true;
        # iconsEnabled = true;
        theme = "startify";
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
        nvim-web-devicons
      ];
  };
}
