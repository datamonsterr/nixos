{
  config,
  pkgs,
  lib,
  ...
}: {
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
  services.xserver.dpi = 144; # 1.5x scaling for 2880x1800 display

  # HiDPI scaling for laptop screen (1.5x scaling)
  environment.variables = {
    GDK_SCALE = "2"; 
    GDK_DPI_SCALE = "0.6";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1.0";
    XCURSOR_SIZE = "36"; 
  };

  # Additional laptop-specific overrides can go here
}
