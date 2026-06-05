{ config, pkgs, lib, ... }:
let
  user = "ksanteen";
  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "d504f70dd5e81e4f623004a26ac0269ddc5a5820";
    sha256 = "sha256-Tpu/BLs/P/5KipggGQM8je1BpLpEDVBSAb5qZPXea1k=";
  };
in {
  yazi = {
    enable = true;
    package = pkgs.yazi;
    shellWrapperName = "y";
    settings = {
      manager = { ratio = [ 1 2 4 ]; };
      preview = {
        max_width = 1024;
        max_height = 1024;
        image_quaility = 90;
      };
      plugin = {
        # not working with yazi transition to 0.4
        # prepend_previewers = [
        #   { name = "*/"; run = "eza-preview"; }
        # ];
      };
    };
    plugins = {
      eza-preview = pkgs.fetchFromGitHub {
        owner = "sharklasers996";
        repo = "eza-preview.yazi";
        rev = "7ca4c2558e17bef98cacf568f10ec065a1e5fb9b";
        sha256 = "sha256-ncOOCj53wXPZvaPSoJ5LjaWSzw1omHadKDrXdIb7G5U=";
      };
    };
    theme = { flavor = { use = "catppuccin-mocha"; }; };
    keymap = {
      manager.prepend_keymap = [
        {
          run = "close";
          on = [ "<C-q>" ];
        }
        {
          run = "seek -5";
          on = [ "<A-Up>" ];
          desc = "Scroll up preview";
        }
        {
          run = "seek -5";
          on = [ "<C-u>" ];
          desc = "Scroll up preview";
        }
        {
          run = "seek 5";
          on = [ "<C-d>" ];
          desc = "Scroll down preview";
        }
        {
          run = "seek 5";
          on = [ "<A-Down>" ];
          desc = "Scroll down preview";
        }
        {
          run = "plugin eza-preview";
          on = "E";
          desc = "Toggle tree/list dir preview";
        }
      ];
    };
    flavors = { catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi/"; };
  };
  zoxide = { enable = true; };

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

    initContent = lib.mkBefore ''
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
    settings = {
      init.defaultBranch = "main";
      core = {
        editor = "vim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
      color.pager = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
    includes = [{ path = "~/.config/git/config.local"; }];
    ignores = [ "*.swp" ];
    lfs = { enable = true; };
  };

  delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "hoopoe";
      true-color = "always";
      interactive.keep-plus-minus-markers = false;
      decorations = {
        commit-decoration-style = "#69db7c ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "#69db7c box";
        hunk-header-file-style = "#ffa8b4";
        hunk-header-line-number-style = "#69db7c";
        hunk-header-style = "file line-number syntax";
      };
      hoopoe = {
        minus-style = "syntax #3D0100";
        minus-emph-style = "normal #5C0200";
        minus-non-emph-style = "syntax #3D0100";
        plus-style = "syntax #032800";
        plus-emph-style = "normal #044700";
        plus-non-emph-style = "syntax #032800";
        minus-empty-line-marker-style = "normal #7a2936";
        plus-empty-line-marker-style = "syntax #225c2b";
        commit-decoration-style = "#69db7c ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "#69db7c box";
        hunk-header-file-style = "#ffa8b4";
        hunk-header-line-number-style = "#69db7c";
        hunk-header-style = "file line-number syntax";
        syntax-theme = "Monokai Extended Bright";
        zero-style = "syntax";
      };
    };
  };

  gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
      hosts = [ "https://github.com" "https://gist.github.com" ];
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
    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };
    plugins = with pkgs.fishPlugins; [
      {
        name = "autopair";
        src = autopair.src;
      }
      {
        name = "bobthefish";
        src = bobthefish.src;
      }
      {
        name = "forgit";
        src = forgit.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "fish-exa"; # TODO derive with proper install/uninstall
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
      cursor = { style = "Block"; };

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

  wezterm = {
    enable = true;
    extraConfig =
      # lua
      ''
        local wezterm = require 'wezterm'
        local act = wezterm.action
        return {
          font = wezterm.font("MesloLGS NF"),
          font_size = 14.0,
          color_scheme = 'Catppuccin Mocha (Gogh)',
          hide_tab_bar_if_only_one_tab = true,
          keys = {
            {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
            {
              key = 'o', mods="CMD", -- URL quick-select (multiplexer-agnostic)
              action = act.QuickSelectArgs {
                patterns = { "https?://\\S+" },
                action = wezterm.action_callback(function(window, pane)
                  local url = window:get_selection_text_for_pane(pane)
                  if url and #url > 0 then
                    wezterm.open_with(url)
                  end
                end),
              },
            },
          }
        }
      '';
  };

  ssh = {
    enable = true;

    # Trailing glob so a missing file is tolerated (ssh errors on missing
    # non-glob Include paths). Kept as an escape hatch for ad-hoc local
    # entries not worth checking in.
    includes = [ "config.local*" ];

    settings = let
      home = if pkgs.stdenv.hostPlatform.isDarwin
             then "/Users/${user}"
             else "/home/${user}";
    in {
      # Required under the new RFC42-style schema in place of the old
      # `enableDefaultConfig = false`. Empty body = no global defaults.
      "*" = { };

      "github-work" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "${home}/.ssh/keys/tcgh";
        IdentitiesOnly = true;
        AddKeysToAgent = true;
      };

      "github" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "${home}/.ssh/keys/gitkey";
        IdentitiesOnly = true;
        AddKeysToAgent = true;
      };
    };
  };

  zellij = {
    enable = true;

    # Auto-start on every fish shell is intentionally off; launch zellij explicitly.
    enableFishIntegration = false;

    settings = {
      default_shell = "${pkgs.fish}/bin/fish";
      # Single-line tab+status bar (no separate mode hint bar).
      default_layout = "compact";
      pane_frames = false;
      mouse_mode = true;
      copy_on_select = true; # mouse drag → clipboard
      copy_clipboard = "system"; # OSC52 — works over SSH too
      copy_command =
        if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wl-copy";

      # Session persistence — restore layout + scrollback on re-attach.
      session_serialization = true;
      serialize_pane_viewport = true;
      scrollback_lines_to_serialize = 10000;
      serialization_interval = 600;

      support_kitty_keyboard_protocol = true;

      theme = "gruvbox-dark";
    };

    # Layered on top of zellij defaults — only what differs from upstream.
    # Defaults still in effect:
    #   Ctrl-s → Scroll mode (then `s` to search, n/N to jump matches)
    #   Ctrl-p / Ctrl-t / Ctrl-n / Ctrl-o → Pane / Tab / Resize / Session modes
    #   Alt h/j/k + Alt arrows → pane focus
    #   Alt n → NewPane, Alt = / Alt - → resize
    extraConfig = ''
      keybinds {
          shared_except "locked" {
              bind "Alt z" { ToggleFocusFullscreen; }      // zoom pane
              bind "Alt p" { ToggleTab; }                  // jump to previously-active tab
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt 6" { GoToTab 6; }
              bind "Alt 7" { GoToTab 7; }
              bind "Alt 8" { GoToTab 8; }
              bind "Alt 9" { GoToTab 9; }

              bind "Alt c" { NewTab; }                     // create tab
              bind "Alt x" { CloseFocus; }                 // kill pane
              bind "Alt ," { SwitchToMode "RenameTab"; TabNameInput 0; }  // rename
          }
      }
    '';
  };
}
