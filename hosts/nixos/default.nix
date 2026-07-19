{ config, inputs, pkgs, ... }:

let user = "ksanteen";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK//F4D06X/qtiPFHb7Cbkkou2PBJBA1Fcd6NcrTQTzr" ]; in
{
  imports = [
    ../../modules/nixos/hardware-configuration.nix
    ../../modules/nixos/zen-browser.nix
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
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = false;
      };
      systemd-boot = {
	enable = true;
        configurationLimit = 10;
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

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
    SuspendState = "mem";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    networkmanager.enable = true;
    networkmanager.plugins = with pkgs; [
      networkmanager-strongswan
    ];

    # charon-nm (strongSwan's NetworkManager plugin) installs a policy-routing
    # rule that sends all non-IPsec-marked traffic through a table (210, from
    # its fwmark 0xd2) containing the tunnel's routes. Without an explicit
    # main-table route to the VPN gateway itself, resolving the path to the
    # gateway recurses back into that same table and the tunnel never
    # connects. Confirmed live with:
    #   ip rule add to 158.160.24.80 lookup main priority 100
    # Scoped by CONNECTION_UUID so it only fires for the "VPN abcde" profile.
    networkmanager.dispatcherScripts = [{
      type = "basic";
      source = pkgs.writeShellScript "vpn-abcde-routing-fix" ''
        set -eu

        vpn_abcde_uuid="fb3bad7f-8ee6-4824-a748-fcdbeebfc7a9"
        vpn_abcde_gateway="158.160.24.80"
        rule_priority="100"

        if [ "''${CONNECTION_UUID:-}" != "$vpn_abcde_uuid" ]; then
          exit 0
        fi

        case "$2" in
          vpn-up)
            ${pkgs.iproute2}/bin/ip rule add to "$vpn_abcde_gateway" lookup main priority "$rule_priority" 2>/dev/null || true
            ;;
          vpn-down)
            ${pkgs.iproute2}/bin/ip rule del to "$vpn_abcde_gateway" lookup main priority "$rule_priority" 2>/dev/null || true
            ;;
        esac
      '';
    }];

    hostName = "borealis"; # Define your hostname.
    useDHCP = false;
    interfaces."wlp4s0".useDHCP = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];

    inputMethod = {
      enable = true;
      type = "ibus";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # console.useXkbConfig's generated keymap (via ckbcomp) binds plain Alt
  # (no Control) on Left/Right and F1-F12 to Decr_Console/Incr_Console/
  # Console_N — legacy fallbacks for keyboards without F-keys/Ctrl. Those
  # are kernel-level VT-switch actions, so they fire even inside the
  # graphical Pantheon/gala session, stealing Alt+Left/Right and Alt+F1-F12
  # from window management. Rebind just the bare-Alt states back to plain
  # keysyms right after the console keymap loads; Ctrl+Alt+F1-F12 keeps
  # working as the real VT-switch shortcut since it isn't touched here.
  systemd.services.systemd-vconsole-setup.serviceConfig.ExecStartPost =
    let
      fixupKeymap = pkgs.writeText "no-vt-switch-alt.map" ''
        alt keycode 105 = Left
        alt keycode 106 = Right
        alt keycode 59 = F1
        alt keycode 60 = F2
        alt keycode 61 = F3
        alt keycode 62 = F4
        alt keycode 63 = F5
        alt keycode 64 = F6
        alt keycode 65 = F7
        alt keycode 66 = F8
        alt keycode 67 = F9
        alt keycode 68 = F10
        alt keycode 87 = F11
        alt keycode 88 = F12
      '';
    in "-${pkgs.kbd}/bin/loadkeys -q ${fixupKeymap}";

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
      settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "lock";
        HandlePowerKey = "suspend";
      };
    };

    pantheon.apps.enable = true;

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
      videoDrivers = [ "modesetting" ];

      displayManager.lightdm = {
        enable = true;
        greeters.pantheon.enable = true;
      };

      # Turn Caps Lock into Ctrl
      xkb.layout = "us";
      xkb.options = "ctrl:nocaps";
    };

    desktopManager = {
      pantheon = {
        enable = true;
        extraWingpanelIndicators = with pkgs; [
          monitor
          wingpanel-indicator-namarupa
        ];
      };
    };

    displayManager.defaultSession = "pantheon-wayland";

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
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
  ];

  environment.systemPackages = with pkgs; [
    inetutils
    pciutils
  ];

  # charon-nm (spawned by the NetworkManager strongSwan plugin) aborts immediately
  # if /etc/strongswan.conf is missing. Debian/Ubuntu ship this via the
  # network-manager-strongswan package; NixOS doesn't populate /etc, so declare it.
  # load_modular relies on strongswan.d/charon/*.conf fragments to enable each
  # plugin, but those ship empty in this derivation, so list plugins explicitly.
  # This nixpkgs strongswan build has no standalone sha1/sha2/aes/md5 plugins —
  # those algorithms come from the openssl plugin instead.
  environment.etc."strongswan.conf".text = ''
    charon-nm {
      load = random nonce openssl pem pkcs1 pkcs8 x509 revocation constraints pubkey eap-identity eap-mschapv2 kernel-netlink socket-default stroke updown
    }
  '';

  system.stateVersion = "21.05"; # Don't change this

}
