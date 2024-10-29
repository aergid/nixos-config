{
  programs.nixvim.plugins.auto-save = {
    enable = true;
    settings = {
      condition = ''
        function(buf)
          local fn = vim.fn
          local utils = require("auto-save.utils.data")
          local bname = vim.api.nvim_buf_get_name(buf)

          if utils.not_in(fn.getbufvar(buf, "&filetype"),
            {'gitcommit', 'gitrebase', 'oil'}
          ) and not string.find(bname , "kubectl") then
            return true
          end
          return false
        end
      '';
    };
  };
}
