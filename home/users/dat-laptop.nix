{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [../common.nix];

  # Laptop-specific configuration for dat

  # Laptop-specific packages and configuration
  home.packages = with pkgs; [
    # GUI applications
    firefox
    vscode
    gimp

    # Media
    vlc

    # Communication
    discord

    # Development GUI tools
    postman
    dbeaver-bin

    # System tools with GUI
    gparted
    filezilla

    # Laptop-specific tools
    powertop
    acpi
    
    # GNOME-specific tools
    gnome-tweaks
    dconf-editor
  ];

  # Common config files (GNOME uses its own settings, but keep some useful configs)
  home.file.".config/ghostty/config".source = ../../assets/config/ghostty/config;
  home.file.".config/zathura/zathurarc".source = ../../assets/config/zathura/zathurarc;

  # Wallpapers
  home.file.".local/share/backgrounds".source = ../../assets/backgrounds;

  # Laptop-specific environment variables with HiDPI scaling for GNOME
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
  };

  # XDG directories
  xdg.configHome = "${config.home.homeDirectory}/.config";
  xdg.dataHome = "${config.home.homeDirectory}/.local/share";
  xdg.cacheHome = "${config.home.homeDirectory}/.cache";
}
