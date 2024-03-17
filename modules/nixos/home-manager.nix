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
