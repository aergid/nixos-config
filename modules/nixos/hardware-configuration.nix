{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
  boot.kernelParams = [ "mem_sleep_default=deep" "acpi_rev_override=5" "i915.enable_guc=2" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  hardware.rtl-sdr.enable = true;
  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.support32Bit = true;    ## If compatibility with 32-bit applications is desired.

  # On NixOS 24.05 or older, this option must be set:
  #sound.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  services.pulseaudio.enable = false;


  # Video support (Skylake HD Graphics 520) - iHD (intel-media-driver) is the
  # modern default for Gen9+; intel-vaapi-driver (i965) stays installed as a
  # fallback for apps that need it, but is not forced via LIBVA_DRIVER_NAME.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };


  fileSystems."/" =
    { device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  # Without this, HandleLidSwitch=suspend-then-hibernate can silently
  # degrade into "power off, cold boot" instead of actually resuming.
  boot.resumeDevice = "/dev/disk/by-label/swap";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
