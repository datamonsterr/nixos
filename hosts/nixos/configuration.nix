{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use systemd-boot on UEFI systems (recommended) instead of GRUB
  # This fixes: "You must set the option 'boot.loader.grub.devices' ..."
  boot.loader.systemd-boot.enable = true;
  # Allow writing EFI variables (needed for installing/updating the boot entry)
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings = {
      General = {
        Experimental = true; # enables experimental features like battery reporting
      };
    };
  };

  # Enable Bluetooth service
  services.blueman.enable = true;
}
