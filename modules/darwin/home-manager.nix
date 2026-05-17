{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  user = "ksanteen";
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix {inherit config pkgs;};
  additionalFiles = import ./files.nix {inherit user config pkgs;};
  t-smart-tmux-session-manager = pkgs.tmuxPlugins.t-smart-tmux-session-manager.overrideAttrs (previousAttrs: {
    postInstall =
      (previousAttrs.postInstall or "")
      + ''
        mkdir $out/bin
        cp $out/share/tmux-plugins/t-smart-tmux-session-manager/bin/t $out/bin
        chmod +x $out/bin/t
      '';
  });
in {
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      #      "1password" = 1333542190;
      #      "wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    # Rename pre-existing files (created imperatively or by other tools) out of
    # the way when home-manager wants to manage that path. Without this, the
    # activation aborts on first conflict.
    backupFileExtension = "hm-backup";
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = [t-smart-tmux-session-manager] ++ pkgs.callPackage ./packages.nix {inherit pkgs;};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        # Create empty stubs for the local identity includes if absent, so the
        # ssh/git Include directives always resolve. Never overwrites.
        activation.bootstrapIdentityIncludes = lib.hm.dag.entryAfter ["writeBoundary"] ''
          for f in "$HOME/.ssh/config.local" "$HOME/.config/git/config.local"; do
            if [ ! -e "$f" ]; then
              $DRY_RUN_CMD mkdir -p "$(dirname "$f")"
              $DRY_RUN_CMD touch "$f"
              $DRY_RUN_CMD chmod 600 "$f"
            fi
          done
        '';
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib;};

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    {path = "/Applications/Vivaldi.app/";}
    {path = "/Applications/Telegram.app/";}
    # {path = "${pkgs.alacritty}/Applications/Alacritty.app/";}
    {path = "${pkgs.wezterm}/Applications/WezTerm.app/";}
    {path = "/Applications/Tidal.app/";}
    {path = "/Applications/VLC.app/";}
    {path = "/System/Applications/Photos.app/";}
    #  { path = "/System/Applications/Facetime.app/"; }
    #  { path = "/System/Applications/Messages.app/"; }
    #  { path = "/System/Applications/Music.app/"; }
    #  { path = "/System/Applications/News.app/"; }
    #  { path = "/System/Applications/Photo Booth.app/"; }
    #  { path = "/System/Applications/TV.app/"; }
    #  { path = "/System/Applications/Home.app/"; }
    #  {
    #    path = "${config.users.users.${user}.home}/.local/share/";
    #    section = "others";
    #    options = "--sort name --view grid --display folder";
    #  }
    #  {
    #    path = "${config.users.users.${user}.home}/.local/share/downloads";
    #    section = "others";
    #    options = "--sort name --view grid --display stack";
    #  }
  ];
}
