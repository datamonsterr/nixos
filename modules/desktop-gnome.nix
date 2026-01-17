{
  config,
  pkgs,
  lib,
  ...
}: {
  # GNOME Desktop Environment configuration

  # Enable X11 and GNOME
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable GNOME core apps and services
  services.gnome.core-apps.enable = true; # Keep core utilities
  services.gnome.gnome-keyring.enable = true;
  
  # Keyboard: swap Caps Lock and Escape
  services.xserver.xkb.options = "caps:swapescape";
  console.useXkbConfig = true;

  # Input Method: fcitx5 + Unikey (Vietnamese Telex)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-unikey
        fcitx5-gtk
        (libsForQt5.fcitx5-qt)
        (qt6Packages.fcitx5-qt)
        fcitx5-configtool
      ];
    };
  };

  # XDG Desktop Portal for GNOME
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "gnome";
  };

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    # GNOME Extensions and Tools
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.user-themes
    
    # Utilities that work well with GNOME
    pavucontrol
    flameshot
    
    # Power management
    brightnessctl
    pamixer
    playerctl
    
    # Additional tools
    dconf-editor
    gnome-extensions-cli
  ];

  # Enable GNOME services
  services.upower.enable = true;
  services.acpid.enable = true;
  
  # Enable libinput for touchpad
  services.libinput.enable = true;

  # Exclude some default GNOME apps if desired
  environment.gnome.excludePackages = with pkgs; [
    # gnome-tour
    # epiphany # GNOME Web browser
    # geary # Email client
    # totem # Video player
  ];
}
