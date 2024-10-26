{
  programs.nixvim.plugins.barbar = {
    enable = true;

    # TODO
    # Integate with one of session plugins
    # https://github.com/romgrk/barbar.nvim?tab=readme-ov-file#features

    keymaps = {
      next.key = "<TAB>";
      previous.key = "<S-TAB>";
      close.key = "<C-x>";
      restore.key = "<C-A-x>";
      pick.key = "<C-A-b>";
      closeAllButCurrent.key = "<leader>o";
    };

    settings = {
      animation = true;
      tabpages = true;
      clickable = true;
      highlight_alternate = true;
      insert_at_end = true;
      focus_on_close = "previous";
      sidebar_filetypes = {
         neo-tree = {event = "BufWipeout"; text = "neo-tree"; align = "left";};
      };
      exclude_ft = [
        "oil"
        "qf"
        "fugitive"
      ];
      exclude_name = [
      ];
      icons = {
        button ="";
        separator_at_end = false;
      };
    };
  };
}
