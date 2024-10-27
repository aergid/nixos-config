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

      # https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/770#discussion-4894073
      # extraOptions = {
      # };
      window.mappings = {
        Z = "expand_all_nodes";
      };

      closeIfLastWindow = true;
      window = {
        width = 30;
        autoExpandWidth = false;
      };
    };
  };
}
