{ config, pkgs, lib, ... }:

let name = "aergid";
    user = "ksanteen";
    email = "develer@gmail.com"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
      }
    ];

    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      export ALTERNATE_EDITOR=""
      export EDITOR="nvim"

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };


  fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      functions -c fish_prompt _my_old_fish_prompt
      function fish_prompt
        if set -q VIFM
          echo -n -s (set_color -b blue white) "(VIFM)" (set_color normal) " "
        end
        _my_old_fish_prompt
      end
    '';
    shellAliases = {
      gc = "git commit";
      gs = "git status";
    };
    plugins = with pkgs.fishPlugins; [
      { name = "autopair"; src = autopair.src; }
      { name = "bobthefish"; src = bobthefish.src; }
      { name = "forgit"; src = forgit.src; }
      { name = "grc"; src = grc.src; }
      { name = "sponge"; src = sponge.src; }
      { name = "z"; src = z.src; }
      {
        name = "fish-exa"; #TODO derive with proper install/uninstall
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-exa";
          rev = "92e5bcb762f7c08cc4484a2a09d6c176814ef35d";
          sha256 = "sha256-kw4XrchvF4SNNoX/6HRw2WPvCxKamwuTVWdHg82Pqac=";
        };
      }
    ];
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  alacritty = {
    enable = true;

    settings = {
      cursor = {
        style = "Block";
      };

      env.term = "xterm-256color";

      window = {
        option_as_alt = "Both"; # | "OnlyRight" | "Both" | "None" # (macos only)
        startup_mode = "Maximized";
        opacity = 1.0;
        padding = {
          x = 0;
          y = 0;
        };
      };

      font = {
        normal = {
          family = "MesloLGS NF";
          # style = "Regular";
        };
        size = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 14)
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
        ];
      };

      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          dim_foreground = "#7f849c";
          bright_foreground = "#cdd6f4";
        };

        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };

        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };

        cursor = {
          text = "#1e1e2e";
          cursor = "#f5e0dc";
        };

        vi_mode_cursor = {
          text = "#1e1e2e";
          cursor = "#b4befe";
        };

        search.matches = {
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };

        search.focused_match = {
          foreground = "#1e1e2e";
          background = "#a6e3a1";
        };

        footer_bar = {
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };

        hints.start = {
          foreground = "#1e1e2e";
          background = "#f9e2af";
        };

        hints.end = {
          foreground = "#1e1e2e";
          background = "#a6adc8";
        };

        selection = {
          text = "#1e1e2e";
          background = "#f5e0dc";
        };

        indexed_colors = [
          {
            index = 16;
            color = "#fab387";
          }
          {
            index = 17;
            color = "#f5e0dc";
          }
        ];
      };
    };
  };

  ssh = {
    enable = true;

    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile /home/${user}/.ssh/id_github
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile /Users/${user}/.ssh/id_github
        '')
    ];
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible # sets up sane default bindings
      yank
      tmux-copycat
      tmux-open
      prefix-highlight

      {
        plugin = vim-tmux-navigator;
        extraConfig = ''
          set -g @vim_navigator_mapping_left "C-Left C-n"  # use C-n and C-Left
          set -g @vim_navigator_mapping_right "C-Right C-i"
          set -g @vim_navigator_mapping_up "C-u"
          set -g @vim_navigator_mapping_down "C-e"
          set -g @vim_navigator_mapping_prev ""  # removes the C-\ binding
        '';
      }
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
           set -g @tmux_power_prefix_highlight_pos 'LR'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "xterm-256color";
    prefix = "C-a";
    extraConfig = ''
      # True color settings
      set -g default-terminal "xterm-256color"
      set -ag terminal-overrides ",xterm-256color:Tc"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours
      set -as terminal-overrides ',*:Smxx=\E[9m' # strikethrough

      set -g default-command "${pkgs.fish}/bin/fish"
      set -g default-shell "${pkgs.fish}/bin/fish"

      # automatically renumber tmux windows
      set -g renumber-windows on

      # Enable full mouse support
      set -g mouse on

      # make window/pane index start with 1
      setw -g pane-base-index 1

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------
      # from tmux-plugins/tmux-pain-control

      # window_move_bindings() {
         bind-key -r "<" swap-window -d -t -1
         bind-key -r ">" swap-window -d -t +1
      # }

      # pane_split_bindings() {
         bind-key "|" split-window -h -c "#{pane_current_path}"
         bind-key "\\" split-window -fh -c "#{pane_current_path}"
         bind-key "-" split-window -v -c "#{pane_current_path}"
         bind-key "_" split-window -fv -c "#{pane_current_path}"
         bind-key "%" split-window -h -c "#{pane_current_path}"
         bind-key '"' split-window -v -c "#{pane_current_path}"
      # }
      '';
    };
}
