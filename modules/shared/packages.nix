{ pkgs }:

with pkgs; [
  # General packages for development and system management
  act
  alacritty
  aspell
  aspellDicts.en
  bash-completion
  bat
  btop
  coreutils
  fish
  killall
  neofetch
  openssh
  pandoc
  sqlite
  wget
  zip
  joplin-desktop
  jetbrains.idea-community

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry
  yubikey-manager

  # Cloud-related tools and SDKs
  docker
  docker-compose

  awscli2
  flyctl
  ngrok
  tflint

  # Media-related packages
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf

  # Node.js development tools
  nodePackages.nodemon
  nodePackages.prettier
  nodePackages.npm # globally install npm
  nodejs

  # Text and terminal utilities
  htop
  hunspell
  iftop
  jetbrains-mono
  jq
  ripgrep
  lazygit
  tig
  lazydocker
  ranger
  eza
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k

  # Python packages
  python39
  python39Packages.virtualenv # globally install virtualenv
]
