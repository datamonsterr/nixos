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
    GDK_SCALE = "2"; # Integer scaling for GTK (2x)
    GDK_DPI_SCALE = "0.75"; # Scale down to achieve 1.5x (2 * 0.75 = 1.5)
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "1.5";
    XCURSOR_SIZE = "36"; # 1.5x scaling for cursor
  };

  # Additional laptop-specific overrides can go here
}
