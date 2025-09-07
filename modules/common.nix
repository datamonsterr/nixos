{
  config,
  pkgs,
  lib,
  ...
}: let
  hostname = "nixos";
  username = "dat";
in {
  # Flakes on, everywhere
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree if you ever need it (Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Host & timezone
  networking.hostName = hostname;
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Desktop & input (i3 via GDM)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Note: GNOME Online Accounts and keyring removed - not needed for standalone email clients

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
      # Provide an i3exit-compatible script from assets/script/i3exit
      (pkgs.writeShellScriptBin "i3exit" (builtins.readFile ../assets/script/i3exit))
    ];
  };
  services.libinput.enable = true;

  # Enable ACPI support for laptop function keys
  services.acpid.enable = true;
  services.upower.enable = true;

  # Enable brightness control for users
  programs.light.enable = true;

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
      # Wayland frontend is optional; GNOME Wayland primarily uses GTK/Qt IM modules
      # waylandFrontend = false; # default
    };
  };

  # Network
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # Sound (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Containers: Docker daemon
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };

  # Weekly SSD TRIM
  services.fstrim.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "nixos-config" "docker" "video" "audio"];
    shell = pkgs.zsh;
  };

  # Group with write access to /etc/nixos for non-root git operations
  users.groups."nixos-config" = {};

  # Shell & essentials
  programs.zsh.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "allowed";
          private_browsing = true;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    gnome-tweaks
    psmisc # killall for polybar launch script
    xorg.xrandr # xrandr used in i3 config
    libnotify # notify-send

    # Email clients - choose one or more based on your preference:
    thunderbird # Full-featured GUI email client, excellent Gmail/Outlook support
    # claws-mail         # Lightweight GTK email client, highly configurable
    # neomutt            # Terminal-based, minimal, very powerful
    # aerc               # Modern terminal-based email client
  ];

  # Fonts: Nerd Fonts (Fira Code) + extras for Polybar/icons (25.05 uses pkgs.nerd-fonts.*)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    font-awesome
    unifont
    siji
  ];

  # Font configuration for better rendering
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "full";
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    defaultFonts = {
      serif = ["DejaVu Serif"];
      sansSerif = ["DejaVu Sans"];
      monospace = ["FiraCode Nerd Font"];
    };
  };

  # Ensure /etc/nixos is group-writable by nixos-config and new files inherit perms
  system.activationScripts.nixosEtcWritable = {
    deps = [];
    text = ''
      set -eu
      dir=/etc/nixos
      if [ -d "$dir" ]; then
        # Change group recursively (ignore errors on special files)
        ${pkgs.coreutils}/bin/chgrp -R nixos-config "$dir" || true
        # Group read/write on everything; execute on dirs and already-exec files
        ${pkgs.coreutils}/bin/chmod -R g+rwX "$dir" || true
        # Ensure setgid on directories so new files/dirs inherit the group
        ${pkgs.findutils}/bin/find "$dir" -type d -exec ${pkgs.coreutils}/bin/chmod g+s {} + || true
        # Set default ACL on directories so new files get group rw by default
        ${pkgs.findutils}/bin/find "$dir" -type d -exec ${pkgs.acl}/bin/setfacl -m d:g:nixos-config:rwX {} + || true
        # Also ensure current files have group rw via ACL (harmless if already set by chmod)
        ${pkgs.acl}/bin/setfacl -R -m g:nixos-config:rwX "$dir" || true
      fi
    '';
  };

  services.openssh.enable = true;

  # When HM manages files like ~/.zshrc, back up any existing files instead of failing
  home-manager.backupFileExtension = "backup";

  # Lock to first installed NixOS version on this machine
  system.stateVersion = "25.05";
}
