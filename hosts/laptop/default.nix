{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop-gnome.nix
    ../../modules/laptop.nix
  ];

  # Hostname
  networking.hostName = "laptop";

  # Use systemd-boot on UEFI systems
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # GNOME will handle HiDPI scaling automatically for 2880x1800 display
  # Set fractional scaling in GNOME Settings > Displays
  # Or use gsettings: gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  # Additional laptop-specific overrides can go here
  # Open port 8080 for Cardio server
  networking.firewall.allowedTCPPorts = [8080];
}
