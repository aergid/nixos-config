{pkgs, ...}: {
  programs.nixvim = {
    plugins.tagbar = {
      enable = true;
      package = pkgs.vimPlugins.tagbar;
      extraConfig = {
        show_tag_count = true;
      };
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
