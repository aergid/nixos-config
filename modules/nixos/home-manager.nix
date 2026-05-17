{ config, pkgs, lib, ... }:

let
  user = "ksanteen";
  xdg_configHome  = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };
in
{
  imports = [
    hm/pantheon.nix
    ];
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix { inherit user; };
    # Create empty stubs for the local identity includes if absent, so the
    # ssh/git Include directives always resolve. Never overwrites.
    activation.bootstrapIdentityIncludes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for f in "$HOME/.ssh/config.local" "$HOME/.config/git/config.local"; do
        if [ ! -e "$f" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$f")"
          $DRY_RUN_CMD touch "$f"
          $DRY_RUN_CMD chmod 600 "$f"
        fi
      done
    '';
    stateVersion = "21.05";
  };

  services = {
    #screen-locker = {
    #  enable = true;
    #  inactiveInterval = 10;
    #  lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
    #};

    # Auto mount devices
    udiskie.enable = true;
  };

  programs = shared-programs // {};

}
