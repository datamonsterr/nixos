{
  config,
  pkgs,
  lib,
  ...
}: {
  # Laptop-specific configurations

  # Power Management - TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # CPU frequency scaling
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      
      # Battery thresholds (adjust based on your laptop)
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      
      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };

  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;

  # Enable thermald for thermal management
  services.thermald.enable = true;

  # Battery monitoring
  services.upower.enable = true;

  # Enable Bluetooth for laptop
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # WiFi configuration
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      scrollMethod = "twofinger";
      naturalScrolling = true;
      accelProfile = "adaptive";
      disableWhileTyping = true;
    };
  };

  # Enable laptop brightness control
  programs.light.enable = true;

  # Laptop-specific hardware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # Suspend configuration
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3600
  '';
}
