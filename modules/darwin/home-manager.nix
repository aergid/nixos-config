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

  # Weekly "soft" GC of the per-user Nix profiles. The system-level nix.gc in
  # hosts/darwin/default.nix runs as root and only scans /nix/var/nix/profiles,
  # so it never touches ~/.local/state/nix/profiles. This keeps the last 14 days
  # of user + home-manager generations as fallback, then collects the rest.
  #
  # NIX_REMOTE=daemon is set explicitly because launchd runs with a bare env that
  # hasn't sourced the nix profile. Caveat: the daemon holds no macOS "App
  # Management" grant, so it CANNOT delete store paths containing signed .app
  # bundles (macOS blocks even root), and such a path aborts the whole sweep.
  # Keep GUI apps in Homebrew casks so .apps stay out of the store; clear any
  # stray one manually with a Full-Disk-Access terminal + `sudo nix-collect-garbage`.
  nixGcUser = pkgs.writeShellScript "nix-gc-user-profiles" ''
    set -u
    export NIX_REMOTE=daemon
    for p in profile home-manager; do
      prof="$HOME/.local/state/nix/profiles/$p"
      if [ -e "$prof" ]; then
        ${pkgs.nixVersions.git}/bin/nix-env -p "$prof" --delete-generations 14d || true
      fi
    done
    ${pkgs.nixVersions.git}/bin/nix-collect-garbage || true
  '';
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
        packages = pkgs.callPackage ./packages.nix {inherit pkgs;};
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

      # Weekly soft GC of this user's Nix profiles, Sundays 03:00 — one hour
      # after the root-level system GC. Logs to ~/.local/state/nix-gc-user.log.
      launchd.agents.nix-gc-user = {
        enable = true;
        config = {
          ProgramArguments = ["${nixGcUser}"];
          StartCalendarInterval = [
            {
              Weekday = 0;
              Hour = 3;
              Minute = 0;
            }
          ];
          StandardOutPath = "${config.home.homeDirectory}/.local/state/nix-gc-user.log";
          StandardErrorPath = "${config.home.homeDirectory}/.local/state/nix-gc-user.log";
        };
      };
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    {path = "/Applications/Vivaldi.app/";}
    {path = "/Applications/Telegram.app/";}
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
