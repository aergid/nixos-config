{
  programs.nixvim.plugins.barbar = {
    enable = true;
    focusOnClose = "left";
    sidebarFiletypes.nvimTree = true;

    keymaps = {
      silent = true;

      next = "<TAB>";
      previous = "<S-TAB>";
      close = "<C-x>";
    };
  };
}
