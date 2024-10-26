{
  programs.nixvim.plugins.barbar = {
    enable = true;
    settings = {
      focus_on_close = "left";
      sidebar_filetypes.nvimTree = true;
    };

    # keymaps = {
      # next = "<TAB>";
      # previous = "<S-TAB>";
      # close = "<C-x>";
    # };
  };
}
