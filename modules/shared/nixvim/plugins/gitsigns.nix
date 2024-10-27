{
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "+";
          change.text = "~";
        };
        # signs = {
        #   add.text = "┃";
        #   change.text = "┃";
        #   delete.text = "_";
        #   topdelete.text = "‾";
        #   changedelete.text = "~";
        #   untracked.text = "┆";
        # };
        # signs_staged = {
        #   add.text = "┃";
        #   change.text = "┃";
        #   delete.text = "_";
        #   topdelete.text = "‾";
        #   changedelete.text = "~";
        #   untracked.text = "┆";
        # };
      };
    };

    # From lua plugin examples
    # -- Navigation
    # map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    # map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})
    #
    # -- Actions
    # map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
    # map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
    # map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
    # map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
    # -- Text object
    # map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    # map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')

    keymaps = [
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
