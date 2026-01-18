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
    
    # Clipboard manager for GNOME
    gnome-extensions-cli
  ];

  # Common config files (GNOME uses its own settings, but keep some useful configs)
  home.file.".config/ghostty/config".source = ../../assets/config/ghostty/config;
  home.file.".config/zathura/zathurarc".source = ../../assets/config/zathura/zathurarc;

  # Wallpapers
  home.file.".local/share/backgrounds".source = ../../assets/backgrounds;

  # GNOME dconf settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "catppuccin-mocha-dark-cursors";
      cursor-size = 20;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = true;  # Natural scroll for touchpad
      disable-while-typing = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;  # Traditional scroll for mouse
    };
    # Clipboard manager keyboard shortcut (Super+V)
    "org/gnome/shell/keybindings" = {
      toggle-message-tray = ["<Super>v"];  # Override default Super+V
    };
    # Custom keybinding for clipboard history
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>v";
      command = "gnome-extensions prefs clipboard-indicator@tudmotu.com";
      name = "Clipboard Manager";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
  };

  # Laptop-specific environment variables with HiDPI scaling for GNOME
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    XCURSOR_SIZE = "20";  # Smaller cursor
    XCURSOR_THEME = "catppuccin-mocha-dark-cursors";  # Cute cat-themed cursor
  };

  # XDG directories
  xdg.configHome = "${config.home.homeDirectory}/.config";
  xdg.dataHome = "${config.home.homeDirectory}/.local/share";
  xdg.cacheHome = "${config.home.homeDirectory}/.cache";
}
