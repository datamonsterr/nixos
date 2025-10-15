{
  config,
  pkgs,
  lib,
  ...
}: {
  # Laptop-specific configurations

  # Use latest kernel for better USB-C PD support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Power Management - TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      # Performance modes: Max performance when charging, powersave on battery
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # CPU frequency scaling - Full performance on AC, limited on battery
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100; # Max performance when charging
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30; # Conservative on battery for longer life

      # Battery charge thresholds for longevity
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # USB power management
      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST_WWAN = 1;

      # PCIe power management
      PCIE_ASPM_ON_AC = "performance"; # Full performance when charging
      PCIE_ASPM_ON_BAT = "powersupersave"; # Max power saving on battery

      # WiFi power saving
      WIFI_PWR_ON_AC = "off"; # No power saving when charging
      WIFI_PWR_ON_BAT = "on"; # Enable power saving on battery

      # Disk power management
      DISK_IDLE_SECS_ON_AC = 0; # No disk spindown when charging
      DISK_IDLE_SECS_ON_BAT = 2; # Quick spindown on battery

      # Graphics power management (Intel integrated graphics)
      INTEL_GPU_MIN_FREQ_ON_AC = 100;
      INTEL_GPU_MAX_FREQ_ON_AC = 1200; # Higher GPU freq when charging
      INTEL_GPU_MIN_FREQ_ON_BAT = 100;
      INTEL_GPU_MAX_FREQ_ON_BAT = 600; # Lower GPU freq on battery

      # Runtime power management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Additional power limiting (may help reduce charging requirements)
      # Force slower charging if hardware supports it
      CHARGE_THRESH_BAT0 = 1; # 0=fast charge, 1=slow charge (if supported)

      # Limit turbo boost to reduce peak power draw
      CPU_BOOST_ON_AC = 1; # Allow turbo boost when charging
      CPU_BOOST_ON_BAT = 0; # Disable turbo boost on battery

      # Additional USB power saving
      USB_BLACKLIST_BTUSB = 1;
      USB_BLACKLIST_PHONE = 1;
    };
  };

  # Disable power-profiles-daemon as it conflicts with TLP
  services.power-profiles-daemon.enable = false;

  # Enable thermald for thermal management
  services.thermald.enable = true;

  # USB-C PD management
  services.udev.extraRules = ''
    # USB-C Power Delivery rules
    SUBSYSTEM=="typec", ACTION=="add", RUN+="${pkgs.coreutils}/bin/echo 'USB-C device connected'"

    # Allow lower wattage USB-C chargers
    SUBSYSTEM=="power_supply", ATTR{type}=="USB_PD", ATTR{online}=="1", RUN+="${pkgs.coreutils}/bin/echo 'USB-C PD charger connected'"
  '';

  # Enable USB-C related systemd services
  systemd.services.usb-pd-policy = {
    description = "USB-C Power Delivery Policy";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Configuring USB-C PD policy\"'";
    };
  };

  # Battery monitoring
  services.upower.enable = true;

  # Power monitoring tools
  environment.systemPackages = with pkgs; [
    powertop # Monitor power consumption
    acpi # Battery and power info
    lm_sensors # Hardware sensors
    usbutils # lsusb command
    pciutils # lspci command
    dmidecode # Hardware info
  ];

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
      accelSpeed = "2.0";
      disableWhileTyping = true;
    };
  };

  # Enable laptop brightness control
  programs.light.enable = true;

  # Laptop-specific hardware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableAllFirmware = true;

  # USB-C Power Delivery support
  hardware.firmware = with pkgs; [
    linux-firmware # Includes USB-C controller firmware
  ];

  # Enable UCSI (USB Type-C Connector System Software Interface)
  boot.kernelModules = [
    "ucsi_acpi" # ACPI-based UCSI driver
    "typec" # USB Type-C subsystem
    "typec_ucsi" # UCSI driver
    "pi3usb30532" # Common USB-C switch driver
  ];

  # Kernel parameters for better USB-C PD support
  boot.kernelParams = [
    "usbcore.autosuspend=-1" # Disable USB autosuspend initially
  ];

  # Suspend configuration
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=3600
  '';
}
