{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>n";
        action = ":Neotree action=focus reveal toggle<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>|";
        action = ":Neotree reveal<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>/";
        action = ":Neotree focus<CR>";
        options.silent = true;
      }
    ];


    plugins.neo-tree = {
      enable = true;

      # extraOptions.__raw = ''
      # '';

      # https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/770#discussion-4894073
      window.mappings = {
        Z = "expand_all_nodes";
        O.__raw = ''
        function (state)
          local node = state.tree:get_node()
          if require("neo-tree.utils").is_expandable(node) then
            state.commands["toggle_node"](state)
          else
            state.commands['open'](state)
            vim.cmd('Neotree reveal')
          end
        end
        '';
      };

      closeIfLastWindow = true;
      window = {
        width = 40;
        autoExpandWidth = false;
      };
    };
  };
}
