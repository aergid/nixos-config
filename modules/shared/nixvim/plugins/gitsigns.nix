{
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "+";
          change.text = "~";
        };
      };
    };

    # -- Text object
    # map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    # map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    keymaps = [
      {
        mode = "n";
        key = "<leader>dc";
        action = ":tab split<CR>:Gitsigns diffthis vertical=true<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>dp";
        action = ":tab split<CR>:Gitsigns diffthis ~ vertical=true<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>td";
        action = ":Gitsigns toggle_deleted<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "]c";
        action = ":Gitsigns next_hunk<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "[c";
        action = ":Gitsigns prev_hunk<CR>";
        options.silent = true;
      }
      {
        mode = ["n" "v"];
        key = "<leader>hs";
        action = ":Gitsigns stage_hunk<CR>";
        options.silent = true;
      }
      {
        mode = ["n" "v"];
        key = "<leader>hr";
        action = ":Gitsigns reset_hunk<CR>";
        options.silent = true;
      }
      {
        mode = ["n" "v"];
        key = "<leader>hu";
        action = ":Gitsigns undo_stage_hunk<CR>";
        options.silent = true;
      }
      {
        mode = ["n" "v"];
        key = "<leader>hS";
        action = ":Gitsigns stage_buffer<CR>";
        options.silent = true;
      }
      {
        mode = ["n" "v"];
        key = "<leader>hR";
        action = ":Gitsigns reset_buffer<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>hp";
        action = ":Gitsigns preview_hunk<CR>";
        options.silent = true;
      }
    ];
  };
}
