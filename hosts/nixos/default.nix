{ config, inputs, pkgs, ... }:

let user = "ksanteen";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK//F4D06X/qtiPFHb7Cbkkou2PBJBA1Fcd6NcrTQTzr" ]; in
{
  imports = [
    ../../modules/nixos/hardware-configuration.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  # Supposedly better for the SSD.
  fileSystems."/" = { options = [ "noatime" "nodiratime" "discard" ]; };

  boot = {
    initrd.luks.devices = {
      crypt = {
        device = "/dev/sda2";
        preLVM = true;
      };
    };

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

    loader = {
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" "hid-apple" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    networkmanager.enable = true;
    hostName = "borealis"; # Define your hostname.
    useDHCP = false;
    interfaces."wlp4s0".useDHCP = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    fish.enable = true;

    pantheon-tweaks.enable = true;
  };

  services = {
    logind = {
	lidSwitch = "suspend-then-hibernate";
	lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "lock";
	extraConfig = "HandlePowerKey=suspend";
    };

    pantheon.apps.enable = true;

    autorandr.enable = true;

    #battery optimization subsystem
   # tlp.enable = true;

    #nixos-auto-update.enable = true;
    logrotate = {
      enable = true;
    };

    xserver = {
      enable = true;
      videoDrivers = [ "intel" ];


      # Comment this for AMD GPU
      # This helps fix tearing of windows for Nvidia cards
      # services.xserver.screenSection = ''
      #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #   Option       "AllowIndirectGLXProtocol" "off"
      #   Option       "TripleBuffer" "on"
      # '';

      desktopManager = {
        #xfce = {
        #  enable = true;
        #  noDesktop = false;
        #  enableXfwm = false;
        #};
        pantheon = {
          enable = true;
          extraWingpanelIndicators = with pkgs; [
            monitor
            wingpanel-indicator-ayatana
          ];
        };

      };
      displayManager = {
    #    defaultSession = "xfce+bspwm";
        lightdm = {
          enable = true;
    #      greeters.slick.enable = true;
          greeters.pantheon.enable = true;
        };
      };

      # Tiling window manager
      windowManager.bspwm = {
        enable = true;
      };

      # Turn Caps Lock into Ctrl
      xkb.layout = "us";
      xkb.options = "ctrl:nocaps";

      # Better support for general peripherals
      libinput.enable = true;

    };

    # Let's be able to SSH into this machine
    openssh.enable = true;


    # Enable CUPS to print documents
    # printing.enable = true;
    # printing.drivers = [ pkgs.brlaser ]; # Brother printer driver

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };


  # Enable sound
  # sound.enable = true;

  # Video support
  hardware = {
    opengl.enable = true;
    # pulseaudio.enable = true;
    # hardware.nvidia.modesetting.enable = true;
  };


  # Add docker daemon
  virtualisation = {
    docker = {
      enable = true;
      logDriver = "json-file";
    };
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
       {
         command = "${pkgs.systemd}/bin/reboot";
         options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = with pkgs; [
    dejavu_fonts
    feather-font # from overlay
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    inetutils
  ];

  environment.pantheon.excludePackages = with pkgs.pantheon; [
    elementary-music
    elementary-photos
    elementary-videos
    epiphany
  ];

  system.stateVersion = "21.05"; # Don't change this

}
