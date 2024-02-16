{
  programs.nixvim = {
    plugins.tagbar = {
      enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<C-g>";
        action = ":TagbarToggle<cr>";
        options.silent = true;
      }
    ];
  };
}
