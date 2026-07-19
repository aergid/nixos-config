{pkgs}:
with pkgs; let
  shared-packages = import ../shared/packages.nix {inherit pkgs;};
in
  shared-packages
  ++ [
    # Security and authentication
    keepassxc

    # App and package management
    appimage-run
    gnumake
    cmake
    home-manager
    ulauncher # App launcher, fuzzy search (works on gala — no layer-shell needed)

    # Media and design tools
    celluloid #instead of gnome_mplayer
    mpv
    fontconfig
    font-manager

    # Audio tools
    pavucontrol # Pulse audio controls

    # Messaging and chat applications
    telegram-desktop

    # Testing and development tools
    # Screenshot and recording tools
    flameshot
    simplescreenrecorder

    # Text and terminal utilities
    tree
    unixtools.ifconfig
    unixtools.netstat
    wl-clipboard
    xwininfo # Provides a cursor to click and learn about windows
    xrandr

    # File and system utilities
    inotify-tools # inotifywait, inotifywatch - For file system events
    libnotify
    xdg-utils

    # PDF viewer
    evince
  ]
