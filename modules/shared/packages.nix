{ pkgs }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
with pkgs; [
  mynixvim
  # General packages for development and system management
  act
  alacritty
  aspell
  aspellDicts.en
  bat
  btop
  coreutils
  delta
  fish
  fzf
  gdk
  grc
  jdk21
  jetbrains.idea-community
  joplin-desktop
  killall
  most
  neofetch
  openssh
  pandoc
  sbt-with-scala-native
  scalafmt
  vifm
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  yubikey-manager

  # Cloud-related tools and SDKs
  docker
  docker-compose

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
  eza
  gh
  grpcurl
  htop
  httpie
  hunspell
  iftop
  jetbrains-mono
  jq
  lazydocker
  lazygit
  ncdu_1
  ntfs3g
  p7zip
  ripgrep
  tig
  tmux
  tree
  zsh-powerlevel10k

  # Python packages
  python312
  python312Packages.virtualenv # globally install virtualenv
  python312Packages.pygments
]
