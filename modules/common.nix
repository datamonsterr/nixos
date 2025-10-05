{
  config,
  pkgs,
  lib,
  ...
}: let
  username = "dat";
in {
  # Flakes on, everywhere
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree if you ever need it (Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Host & timezone - hostname will be set by individual host configs
  # networking.hostName is configured per host
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Common system configuration (desktop configs moved to modules/desktop-i3.nix)

  # Network
  networking.networkmanager.enable = true;

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
  programs.nix-ld.enable = true; # For non-root nix
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
    psmisc
    xorg.xrandr
    libnotify
    xdg-utils # For xdg-open and protocol handlers
    gnome-keyring # For secure credential storage
    libsecret # Secret service library
    thunderbird
    appimage-run # For running AppImages
    # Optional AppImage tools:
    # appimagelauncher  # GUI launcher for AppImages
    # appimagekit       # Tools for creating AppImages
    
    # Power management tools
    powertop # Monitor and optimize power consumption
    acpi # ACPI information
    lm_sensors # Hardware monitoring
  ];

  # Enable AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true; # This allows you to run AppImages directly
  };

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
