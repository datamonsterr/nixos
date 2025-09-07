{
  config,
  pkgs,
  lib,
  ...
}: {
  # Server/headless configuration
  
  # Disable X11 and desktop environment
  services.xserver.enable = false;
  
  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
    ports = [ 22 ];
  };
  
  # Firewall configuration for server
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [];
  };
  
  # Disable unnecessary services for server
  services.printing.enable = false;
  services.pipewire.enable = false;
  services.pulseaudio.enable = false;
  sound.enable = false;
  hardware.bluetooth.enable = false;
  
  # Server optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  
  # Minimal package set for server
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    git
    htop
    tree
    tmux
    screen
  ];
}
