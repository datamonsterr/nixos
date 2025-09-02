{ config, pkgs, lib, ... }:

let
  hostname = "nixos";
  username = "dat";
in
{
  # Flakes on, everywhere
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree if you ever need it (Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Host & timezone
  networking.hostName = hostname;
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Desktop & input (GNOME)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.libinput.enable = true;

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

  # Sound (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Weekly SSD TRIM
  services.fstrim.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # Shell & essentials
  programs.zsh.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "allowed";
          private_browsing  = true;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git wget curl vim gnome-tweaks
  ];

  services.openssh.enable = true;

  # When HM manages files like ~/.zshrc, back up any existing files instead of failing
  home-manager.backupFileExtension = "backup";

  # Lock to first installed NixOS version on this machine
  system.stateVersion = "25.05";
}
