{pkgs, ...}:
{
  imports = [
    ./auto-session.nix
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
    colorscheme = "catppuccin-mocha";

    colorschemes = {
      ayu.enable = true;
      catppuccin.enable = true;
      gruvbox.enable = true;
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
        (pkgs.vimUtils.buildVimPlugin {
          name = "floating-help";
          src = pkgs.fetchFromGitHub {
            owner = "hyt589";
            repo = "floating-help";
            rev = "67d58d6";
            sha256 = "sha256-P+nm96eHuyoM3tpWu4xhTckIleQiknmRtWwmc6snKZc=";
          };
        })
      ];

    extraConfigLua = ''
      require('floating-help').setup({
         border = 'rounded',
         ratio = 0.9,
         width = 120
      })
    '';
  };
}
