{
  config,
  pkgs,
  lib,
  ...
}: let
  username = "dat";
  
  # Create a Python environment with all needed packages
  pythonWithPackages = pkgs.python313.withPackages (ps: with ps; [
    numpy
    opencv4
    pandas
    matplotlib
    jupyterlab
    ipykernel
    ipython
    jupyter
    notebook
    uv
  ]);
in {
  # Common home-manager configuration for all devices

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Environment variables
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk11}/lib/openjdk";
    JDK_HOME = "${pkgs.jdk11}/lib/openjdk";
    JAVA_VERSION = "11";
    # Ensure VS Code can find Java tools
    PATH = "$PATH:${pkgs.jdk11}/bin";

    # PostgreSQL development
    PostgreSQL_ROOT = "${pkgs.postgresql}";
    PostgreSQL_INCLUDE_DIR = "${pkgs.postgresql.dev}/include";
    PostgreSQL_LIBRARY = "${pkgs.postgresql}/lib/libpq.so";
    PKG_CONFIG_PATH = "${pkgs.postgresql.dev}/lib/pkgconfig:$PKG_CONFIG_PATH";

    # Force dark theme for all GTK applications
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";

    # Jupyter configuration
    JUPYTER_CONFIG_DIR = "$HOME/.jupyter";
    JUPYTER_DATA_DIR = "$HOME/.local/share/jupyter";
  };

  # Create a stable symlink for VS Code Java configuration
  home.file.".local/share/java/jdk11".source = "${pkgs.jdk11}/lib/openjdk";

  # Common packages for all devices
  home.packages = with pkgs; [
    # Development tools
    git
    zsh
    bash
    gnumake
    cmake
    clang
    clang-tools
    openssl

    # System utilities
    htop
    tree
    wget
    curl
    unzip
    zip

    # Terminal applications
    ghostty
    bat
    ripgrep
    fd
    fzf
    jq
    starship
    xclip
    zoxide

    # Languages & runtimes
    go
    pythonWithPackages
    jdk11
    nodejs_22
    pnpm
    yarn
    nodePackages.typescript
    nodePackages.mermaid-cli
    maven
    wireshark
    feh

    # Development & productivity tools
    vscode
    postman
    flameshot
    obsidian
    pomodoro-gtk
    rars

    # File management & media
    pcmanfm
    pavucontrol
    zathura

    # AWS tools
    awscli2
    aws-sam-cli

    # Container tools
    docker
    lazydocker
    docker-compose
    docker-buildx
    dive

    # System tools
    direnv
    nix-direnv
    nitrogen # wallpaper management

    # Bluetooth tools
    bluez
    bluez-tools
    blueman

    # Python packages for polybar scripts
    python313Packages.i3ipc

    # Themes and icons
    adwaita-icon-theme
    gnome-themes-extra
    gtk-engine-murrine

    # Cloud storage
    rclone

    # Time control
    activitywatch
    
    teams-for-linux
  ];
  # Common programs configuration
  programs.git = {
    enable = true;
    userName = "datamonsterr";
    userEmail = "phamthanhdat17092004@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      push.default = "simple";
    };
  };

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github-datamonsterr" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519_datamonsterr";
        user = "git";
      };

      "github-nuoa" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519_nuoa";
        user = "git";
      };
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # VS Code with Java development extensions
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };

  # direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Firefox browser
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  # Cloud storage with rclone
  programs.rclone = {
    enable = true;
    package = pkgs.rclone;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      gdrive = "/etc/nixos/assets/script/rclone-manager.sh";
      jupyter-manager = "/etc/nixos/assets/script/jupyter-manager.sh";
      jlab = "jupyter lab";
      jnb = "jupyter notebook";
    };

    initContent = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Zoxide initialization with z alias
      eval "$(zoxide init --cmd z zsh)"

      # Custom functions
      mkcd() { mkdir -p "$1" && cd "$1"; }
    '';
  };

  # Zoxide configuration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Common dotfiles
  # Use onChange to copy nvim config so Lazy.nvim can write to lazy-lock.json
  home.activation.nvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.config/nvim
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -av --chmod=u+w \
      ${../assets/config/nvim}/ $HOME/.config/nvim/ \
      --exclude lazy-lock.json
  '';

  # Setup Jupyter kernel for Python
  home.activation.jupyterKernel = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.local/share/jupyter/kernels
    if [ ! -d "$HOME/.local/share/jupyter/kernels/python3" ]; then
      $DRY_RUN_CMD ${pythonWithPackages}/bin/python -m ipykernel install --user --name python3 --display-name "Python 3.13"
    fi
  '';

  home.file.".Xresources".source = ../assets/config/Xresources;

  # Jupyter configuration
  home.file.".jupyter/jupyter_notebook_config.py".source = ../assets/config/jupyter/jupyter_notebook_config.py;

  # AWS configuration
  home.file.".aws/config" = {
    text = ''
      [sso-session nuoa]
      sso_start_url = https://nuoa.awsapps.com/start
      sso_region = us-east-1
      sso_registration_scopes = sso:account:access

      [profile nuoa-beta]
      sso_session = nuoa
      sso_account_id = 070888215368
      sso_role_name = AdministratorAccess
      region = ap-southeast-1
      output = json
    '';
    force = true;
  };

  # rclone configuration - create config directory only
  home.file.".config/rclone/.keep".text = "";

  # Auto-sync service for Google Drive folders from config file
  systemd.user.services."rclone-auto-sync" = {
    Unit = {
      Description = "Auto-sync Google Drive folders from config file";
      After = ["graphical-session-pre.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/assets/script/rclone-autosync.sh run-sync";
      Environment = [
        "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
      ];
    };
  };

  # Timer for periodic sync every 30 minutes
  systemd.user.timers."rclone-auto-sync" = {
    Unit = {
      Description = "Timer for Google Drive auto-sync every 30 minutes";
      Requires = ["rclone-auto-sync.service"];
    };

    Timer = {
      OnStartupSec = "2min"; # 2 minutes after login
      OnUnitActiveSec = "30min"; # Every 30 minutes after that
      Persistent = true;
    };

    Install = {
      WantedBy = ["timers.target"];
    };
  };

  systemd.user.services.aw-server = {
    Unit = {
      Description = "ActivityWatch Server";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.activitywatch}/bin/aw-server --host 127.0.0.1 --port 5600";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.aw-watcher-window = {
    Unit = {
      Description = "ActivityWatch Window Watcher (X11)";
      After = ["aw-server.service" "graphical-session.target"];
      Requires = ["aw-server.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.activitywatch}/bin/aw-watcher-window";
      Restart = "on-failure";
      RestartSec = "10";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.aw-watcher-afk = {
    Unit = {
      Description = "ActivityWatch AFK Watcher";
      After = ["aw-server.service" "graphical-session.target"];
      Requires = ["aw-server.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.activitywatch}/bin/aw-watcher-afk";
      Restart = "on-failure";
      RestartSec = "10";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # Common input method configuration
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [fcitx5-unikey];
    fcitx5.settings = {
      globalOptions = {
        "Hotkey/TriggerKeys" = {
          "0" = "";
        };
      };
      inputMethod = {
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "keyboard-us";
        };
        "Groups/0/Items/0" = {
          "Name" = "keyboard-us";
          "Layout" = "";
        };
        "Groups/0/Items/1" = {
          "Name" = "unikey";
          "Layout" = "";
        };
        "GroupOrder" = {
          "0" = "Default";
        };
      };
    };
  };
}
