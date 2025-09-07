{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [ ../common.nix ];

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
  ];

  # Laptop-specific dotfiles with HiDPI configurations
  home.file.".config/i3/config".source = ../../assets/config-laptop/i3/config;
  home.file.".config/polybar".source = ../../assets/config-laptop/polybar;
  
  # Common config files (no device-specific differences needed)
  home.file.".config/rofi".source = ../../assets/config/rofi;
  home.file.".config/dunst/dunstrc".source = ../../assets/config/dunst/dunstrc;
  home.file.".config/ghostty/config".source = ../../assets/config/ghostty/config;
  home.file.".config/zathura/zathurarc".source = ../../assets/config/zathura/zathurarc;

  # Desktop scripts
  home.file.".local/bin/i3exit" = {
    source = ../../assets/script/i3exit;
    executable = true;
  };
  home.file.".local/bin/random-wallpaper.sh" = {
    source = ../../assets/script/random-wallpaper.sh;
    executable = true;
  };
  
  # Wallpapers
  home.file.".local/share/backgrounds".source = ../../assets/backgrounds;

  # Laptop-specific environment variables with HiDPI scaling
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    # HiDPI scaling for applications
    GDK_SCALE = "1.4";
    GDK_DPI_SCALE = "0.7";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "1.4";
  };

  # XDG directories
  xdg.configHome = "${config.home.homeDirectory}/.config";
  xdg.dataHome = "${config.home.homeDirectory}/.local/share";
  xdg.cacheHome = "${config.home.homeDirectory}/.cache";
}
