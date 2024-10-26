{
  programs.nixvim.plugins.zen-mode = {
    enable = true;

    settings = {
        on_close = ''
          function()
            require("gitsigns.actions").toggle_current_line_blame()
            vim.cmd('IBLEnable')
            vim.opt.relativenumber = true
            vim.opt.signcolumn = "yes:2"
            require("gitsigns.actions").refresh()
          end
        '';
        on_open = ''
          function()
            require("gitsigns.actions").toggle_current_line_blame()
            vim.cmd('IBLDisable')
            vim.opt.relativenumber = false
            vim.opt.signcolumn = "no"
            require("gitsigns.actions").refresh()
          end
        '';
        plugins = {
          gitsigns = {
            enabled = true;
          };
          options = {
            enabled = true;
            ruler = false;
            showcmd = false;
          };
          tmux = {
            enabled = false;
          };
          twilight = {
            enabled = false;
          };
        };
        window = {
          backdrop = 0.95;
          height = 1;
          options = {
            signcolumn = "no";
          };
          width = 0.8;
        };

    };
  };
}

