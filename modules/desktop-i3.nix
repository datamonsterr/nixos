{
  config,
  pkgs,
  lib,
  ...
}: {
  # Desktop i3 configuration with display scaling

  # Desktop & input (i3 via GDM)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraPackages = with pkgs; [
      dmenu
      rofi
      rofi-emoji
      dunst
      picom
      polybarFull
      (haskellPackages.greenclip)
      xautolock
      i3lock
      betterlockscreen
      pavucontrol
      flameshot
      xorg.xkill
      # Tools for function keys
      brightnessctl
      pamixer
      playerctl
      # Wallpaper utilities
      nitrogen
      # Screen management
      arandr
      xorg.xrandr
      # Provide an i3exit-compatible script from assets/script/i3exit
      (pkgs.writeShellScriptBin "i3exit" (builtins.readFile ../assets/script/i3exit))
    ];
  };

  # Enable libinput for mouse/touchpad
  services.libinput.enable = true;

  # ACPI support for function keys
  services.acpid.enable = true;
  services.upower.enable = true;

  # Keyboard: swap Caps Lock and Escape everywhere
  services.xserver.xkb.options = "caps:swapescape";
  # Apply the same XKB config on the Linux console (TTYs)
  console.useXkbConfig = true;

  # Input Method: fcitx5 + Unikey (Vietnamese Telex)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # IM modules for GTK/Qt apps and config GUI
      addons = with pkgs; [
        fcitx5-unikey
        fcitx5-gtk
        (libsForQt5.fcitx5-qt)
        (qt6Packages.fcitx5-qt)
        fcitx5-configtool
      ];
    };
  };

  # Display configuration (will be overridden by laptop/pc specific configs)
  services.xserver.xrandrHeads = []; # Set specific displays in host configs

  # Picom compositor configuration
  services.picom = {
    enable = true;
    backend = "glx";
    settings = {
      # Fading
      fading = true;
      fade-in-step = 0.03;
      fade-out-step = 0.03;
      fade-delta = 10;

      # Shadow
      shadow = true;
      shadow-radius = 7;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-opacity = 0.7;
      shadow-exclude = [
        "name = 'Notification'"
        "class_g = 'Conky'"
        "class_g ?= 'Notify-osd'"
        "class_g = 'Cairo-clock'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Opacity
      active-opacity = 1.0;
      inactive-opacity = 0.95;

      # Blur
      blur-kern = "3x3box";
      blur-method = "kawase";
      blur-strength = 7;

      # Other
      corner-radius = 0;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;
      use-damage = true;
      log-level = "warn";
    };
  };
}
