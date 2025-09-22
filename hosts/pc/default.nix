{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop-i3.nix
  ];

  # Hostname
  networking.hostName = "pc";

  # Use systemd-boot on UEFI systems
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # PC-specific configurations

  # No display scaling needed for PC
  services.xserver.dpi = 96; # Standard DPI for desktop monitors

  # Standard scaling for desktop
  environment.variables = {
    GDK_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "16";
  };

  # Enable Ethernet networking (no WiFi needed typically)
  networking.networkmanager.enable = true;
  # If you want to disable WiFi entirely:
  # networking.networkmanager.wifi.backend = "none";

  # Enable Bluetooth for PC (keyboards, mice, headphones)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # PC performance optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Disable laptop-specific services
  services.tlp.enable = false;
  services.thermald.enable = false;

  # Additional PC-specific packages
  environment.systemPackages = with pkgs; [
    # PC-specific tools
    lm_sensors # hardware monitoring
    stress # system stress testing
    glxinfo # OpenGL information
    vulkan-tools # Vulkan tools
    pciutils # PCI utilities
    usbutils # USB utilities
  ];
}
