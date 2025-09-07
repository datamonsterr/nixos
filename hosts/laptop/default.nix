{config, pkgs, lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop-i3.nix
    ../../modules/laptop.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Use systemd-boot on UEFI systems
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Laptop-specific display configuration with scaling
  services.xserver.dpi = 144;  # Adjust based on your laptop's DPI
  
  # HiDPI scaling for laptop screen
  environment.variables = {
    GDK_SCALE = "1.4";
    GDK_DPI_SCALE = "0.7";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "1.4";
    XCURSOR_SIZE = "24";
  };
  
  # Additional laptop-specific overrides can go here
}
