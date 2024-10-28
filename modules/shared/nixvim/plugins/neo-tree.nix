{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "<leader>nt";
        action = ":Neotree action=focus reveal toggle<CR>";
        options.silent = true;
      }
      #Some times it doesn't actually focus from a split on a first time,
      #so we double commands
      {
        mode = "n";
        key = "<leader>nf";
        action = ":Neotree focus<CR>:Neotree focus<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>nr";
        action = ":Neotree reveal<CR>:Neotree reveal<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>ng";
        action = ":Neotree float git_status<CR>";
        options.silent = true;
      }
    ];


    plugins.neo-tree = {
      enable = true;

      sources = [
        "filesystem"
        "git_status"
      ];

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
