{ pkgs }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents
    (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]);
in with pkgs; [
  # d2  # disabled: nixpkgs unstable wraps d2 with mesa-libgbm + playwright-browsers,
         # which pulls in libdrm (Linux-only) and fails to build on Darwin.
         # See notes/nix-tooling.md.
  gemini-cli
  ueberzugpp
  onyxvim
  # General packages for development and system management
  act
  alacritty
  aspell
  aspellDicts.en
  bat
  btop
  claude-code
  coreutils
  delve
  fish
  go
  gopls
  gofumpt
  gotests
  fzf
  gdk
  grc
  jdk21
  jetbrains.idea
  jetbrains.goland
  # joplin-desktop
  killall
  most
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
  tflint

  # Media-related packages
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-color-emoji
  meslo-lgs-nf

  # Node.js development tools
  # nodePackages.nodemon
  # nodePackages.prettier
  # nodePackages.npm # globally install npm
  # nodejs

  # Text and terminal utilities
  eza
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
  tree
  zsh-powerlevel10k

  # Python packages
  python312
  python312Packages.virtualenv # globally install virtualenv
  python312Packages.pygments
]
