{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [

  firefox
  # Security and authentication
  keepassxc

  # App and package management
  appimage-run
  gnumake
  cmake
  home-manager

  # Media and design tools
  celluloid #instead of gnome_mplayer
  mpv
  fontconfig
  font-manager

  # Productivity tools
  bc # old school calculator
  galculator

  # Audio tools
  pavucontrol # Pulse audio controls

  # Messaging and chat applications
  tdesktop # telegram desktop

  # Testing and development tools
  # Screenshot and recording tools
  flameshot
  simplescreenrecorder

  # Text and terminal utilities
  feh # Manage wallpapers
  screenkey
  tree
  unixtools.ifconfig
  unixtools.netstat
  xclip # For the org-download package in Emacs
  xorg.xwininfo # Provides a cursor to click and learn about windows
  xorg.xrandr

  # File and system utilities
  inotify-tools # inotifywait, inotifywatch - For file system events
#  i3lock-fancy-rapid
  libnotify
  xdg-utils

  # Other utilities
  xdotool

  # PDF viewer
  evince
]
