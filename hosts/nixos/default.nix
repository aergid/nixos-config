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
    # kernelPackages = pkgs.linuxPackages_latest;
    # bluetooth keyboard not working after resume from hibernate
    # https://github.com/NixOS/nixpkgs/issues/286044
    kernelPackages = pkgs.pkgs.linuxPackages_6_6;
    kernelModules = [ "uinput" "hid-apple" ];
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

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
    package = pkgs.nixVersions.git;
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
  };

  # Enable powertop
  powerManagement.powertop.enable = true;

  services = {
    logind = {
	    lidSwitch = "suspend-then-hibernate";
	    lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "lock";
	    extraConfig = "HandlePowerKey=suspend";
    };

    # pantheon.apps.enable = true;

    autorandr.enable = true;

    #battery optimization subsystem

    # Better scheduling for CPU cycles - thanks System76!!!
    system76-scheduler.settings.cfsProfiles.enable = true;
    power-profiles-daemon.enable = false; # conflicts with tlp
    # Enable thermald (only necessary if on Intel CPUs)
    thermald.enable = true;
    tlp = {
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        START_CHARGE_THRESH_BAT0 = 90;
        STOP_CHARGE_THRESH_BAT0 = 96;
      };
    };

    #nixos-auto-update.enable = true;
    logrotate = {
      enable = true;
    };

    xserver = {
      enable = true;
      videoDrivers = [ "intel" ];
      # services.xserver.screenSection = ''
      #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #   Option       "AllowIndirectGLXProtocol" "off"
      #   Option       "TripleBuffer" "on"
      # '';

      desktopManager = {
        gnome.enable = true;
        #xfce = {
        #  enable = true;
        #  noDesktop = false;
        #  enableXfwm = false;
        #};
        # pantheon = {
        #   enable = true;
        #   extraWingpanelIndicators = with pkgs; [
        #     monitor
        #     wingpanel-indicator-ayatana
        #   ];
        # };

      };
      displayManager = {
        gdm.enable = true;
    #    defaultSession = "xfce+bspwm";
    #     lightdm = {
    #       enable = true;
    # #      greeters.slick.enable = true;
    #       greeters.pantheon.enable = true;
    #     };
      };

      # Tiling window manager
      # windowManager.bspwm = {
      #   enable = true;
      # };

      # Turn Caps Lock into Ctrl
      xkb.layout = "us";
      xkb.options = "ctrl:nocaps";

    };

    # Better support for general peripherals
    libinput.enable = true;


    # Let's be able to SSH into this machine
    openssh.enable = true;

    # Sync state between machines
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/${user}/.local/share/syncthing";
      configDir = "/home/${user}/.config/syncthing";
      user = "${user}";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = {};
        options.globalAnnounceEnabled = false; # Only sync on LAN
      };
    };

    # Enable CUPS to print documents
    # printing.enable = true;
    # printing.drivers = [ pkgs.brlaser ]; # Brother printer driver

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };


  # Enable sound
  # sound.enable = true;

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
    pciutils
    # pantheon-tweaks
  ];

  # environment.pantheon.excludePackages = with pkgs.pantheon; [
  #   elementary-music
  #   elementary-photos
  #   elementary-videos
  #   epiphany
  # ];

  system.stateVersion = "21.05"; # Don't change this

}
