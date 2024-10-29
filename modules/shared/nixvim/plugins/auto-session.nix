{
  programs.nixvim = {

    keymaps = [
      {
        mode = "n";
        key = "<leader>fs";
        action = ":SessionSearch<CR>";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = ":SessionDelete<CR>";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = ":SessionSave<CR>";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action = ":SessionToggleAutoSave<CR>";
      }
    ];

    plugins.auto-session = {
      enable = true;

      settings = {
        # auto_create = false; -- no auto creation
        bypass_save_filetypes = [
          "alpha"
          "netrw"
          "oil"
        ];
        pre_save_cmds = [
          "Neotree close"
        ];
        post_restore_cmds = [
          "Neotree filesystem show"
          "wincmd ="
        ];
      };
    };

  };
}
