{ config, pkgs, lib, home-manager, nixvim, ... }:

let
  user = "ksanteen";
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
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
    users.${user} = { pkgs, config, lib, ... }:{
      imports = [
        nixvim.homeManagerModules.nixvim
        ../shared/neovim
      ];
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Photos.app/"; }
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Telegram.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "/Applications/Vivaldi.app/"; }
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    { path = "${pkgs.joplin-desktop}/Applications/Joplin.app/"; }
    { path = "/Applications/VLC.app/"; }
    { path = "/Applications/Qobuz.app/"; }
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
