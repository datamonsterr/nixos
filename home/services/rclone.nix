{
  config,
  pkgs,
  lib,
  ...
}: {
  # rclone configuration for cloud storage
  programs.rclone = {
    enable = true;
  };

  # Create the rclone config directory and allow manual configuration
  home.file.".config/rclone/.keep".text = "";

  # Optionally, you can create systemd services for mounting
  systemd.user.services = {
    # Example service for mounting Google Drive
    "rclone-gdrive-personal" = {
      Unit = {
        Description = "RClone mount personal Google Drive";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/GoogleDrive-Personal";
        ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive-personal: %h/GoogleDrive-Personal --config=%h/.config/rclone/rclone.conf --vfs-cache-mode writes --vfs-cache-max-age 100h --vfs-read-ahead 0 --buffer-size 16M";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/GoogleDrive-Personal";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "%i";
        Group = "users";
        Environment = [
          "PATH=/run/wrappers/bin/:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        ];
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # OneDrive Work service
    "rclone-onedrive-work" = {
      Unit = {
        Description = "RClone mount work OneDrive";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/OneDrive-Work";
        ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive-work: %h/OneDrive-Work --config=%h/.config/rclone/rclone.conf --vfs-cache-mode writes --vfs-cache-max-age 100h --vfs-read-ahead 0 --buffer-size 16M";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/OneDrive-Work";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "%i";
        Group = "users";
        Environment = [
          "PATH=/run/wrappers/bin/:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        ];
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # OneDrive Education service
    "rclone-onedrive-edu" = {
      Unit = {
        Description = "RClone mount education OneDrive";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "notify";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/OneDrive-Education";
        ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive-edu: %h/OneDrive-Education --config=%h/.config/rclone/rclone.conf --vfs-cache-mode writes --vfs-cache-max-age 100h --vfs-read-ahead 0 --buffer-size 16M";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/OneDrive-Education";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "%i";
        Group = "users";
        Environment = [
          "PATH=/run/wrappers/bin/:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        ];
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # Create mount point directories
  home.file."GoogleDrive-Personal/.keep".text = "";
  home.file."OneDrive-Work/.keep".text = "";
  home.file."OneDrive-Education/.keep".text = "";
}
