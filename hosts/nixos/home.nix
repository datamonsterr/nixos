{
  config,
  pkgs,
  lib,
  ...
}: let
  username = "dat";
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # --- Input Method: fcitx5 + Unikey (Vietnamese Telex) ---
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [fcitx5-unikey];
      # Prefer using IM modules; still set env for broad compatibility (Xwayland/legacy)
      settings = {
        # Default input methods order: US keyboard first, then Unikey
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            DefaultLayout = "us";
            "Default Layout" = "us";
            DefaultIM = "unikey";
          };
          # Items: keyboard-us (system US layout) and Unikey IME
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "unikey";
        };
        globalOptions = {
          Hotkey = {
            # Enable switch with trigger keys like Ctrl+Space
            EnumerateWithTriggerKeys = true;
          };
        };
        addons = {
          # Make Unikey default to Telex typing method
          unikey.globalSection = {
            InputMethod = 0; # 0: Telex, 1: VNI, 2: Simple Telex, etc.
          };
        };
      };
      waylandFrontend = false; # Rely on GTK/Qt modules under GNOME Wayland
    };
  };

  # ---- Toolchain & CLIs ----
  home.packages = with pkgs; [
    # Languages / SDKs
    jdk11
    go
    python313

    # Node & managers
    nodejs_22
    yarn

    # Tools
    vscode
    awscli2
    aws-sam-cli
    tmux
    ghostty
    pcmanfm
    rofi
    rofi-emoji
    dunst
    pavucontrol
    flameshot
    postman
    maven

    # polybar script deps (align with python313 to avoid conflicts)
    python313Packages.i3ipc

    # Containers
    docker
    lazydocker
    docker-compose
    docker-buildx
    dive

    # Quality-of-life
    direnv
    nix-direnv
    starship
    git

    # Background/wallpaper
    nitrogen

    # Fonts
    fira-code
    
    # Node pkg
    nodePackages.typescript
    nodePackages.mermaid-cli
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = ["git" "z"];
    };

    initContent = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.git = {
    enable = true;
    userName = "datamonsterr";
    userEmail = "phamthanhdat17092004@gmail.com";
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

  # Neovim: source your repo into ~/.config/nvim so it's identical to the linked setup
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # VS Code + Docker extension (GUI for Docker inside VS Code)
  programs.vscode = {
    enable = true;
    # Ensure we use the same VS Code package already installed above
    package = pkgs.vscode;
    profiles = {
      "default" = {
        extensions = with pkgs.vscode-extensions; [
          ms-azuretools.vscode-docker
        ];
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  # Your older .zshrc PATH/env equivalents
  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    # GTK HiDPI scaling
    GDK_SCALE = "1";          # must be integer
    GDK_DPI_SCALE = "1.5";    # fractional text/UI scale

    # Qt HiDPI scaling
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1.5";
    QT_FONT_DPI = "144";
    
    # Cursor size for X11/i3 and Wayland (48 = 2x scale)
    XCURSOR_SIZE = "48";
    
    # Better font rendering for applications
    FREETYPE_PROPERTIES = "truetype:interpreter-version=38";
  };
  
  xresources.properties = {
    # 150% of 96 DPI → crisp fonts in X apps
    "Xft.dpi" = "144";
    "Xft.antialias" = "true";
    "Xft.hinting" = "true";
    "Xft.hintstyle" = "hintslight";
    "Xft.rgba" = "rgb";
    "Xft.lcdfilter" = "lcddefault";
    "Xft.autohint" = "false";
    # 2x cursor size for X11/i3
    "Xcursor.size" = "96";
  };

  home.sessionPath = [
    "$HOME/bin"
    "/usr/local/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  # GNOME fractional scaling (Home-Manager owns dconf)
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
    };

    # Swap Caps Lock and Escape in GNOME (Wayland-aware)
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["caps:swapescape"];
    };

    # Theme, dark mode, and UI scale
    "org/gnome/desktop/interface" = {
      accent-color = "teal";
      color-scheme = "prefer-dark";
      text-scaling-factor = 1.25;
      cursor-size = 48;  # 2x scale (default is 24)
    };

    # Desktop and lock screen backgrounds
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/geometrics-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/geometrics-d.jxl";
      primary-color = "#26a269";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/geometrics-l.jxl";
      primary-color = "#26a269";
      secondary-color = "#000000";
    };

    # Mouse & touchpad tweaks
    "org/gnome/desktop/peripherals/mouse" = {
      speed = -0.035;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      edge-scrolling-enabled = true;
      speed = -0.12;
      two-finger-scrolling-enabled = false;
    };

    # Favorite apps in dash
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
        "code.desktop"
        "firefox.desktop"
      ];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
    };

    "org/gnome/Console" = {
      use-system-font = false;
      custom-font = "Fira Code 12";
    };
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/nvim";
      recursive = true;
    };

    "i3/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/i3/config";
    };

    "polybar" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/polybar";
      recursive = true;
    };

    "dunst/dunstrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/dunst/dunstrc";
    };

    "ghostty/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/ghostty/config";
    };

    "rofi" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/rofi";
      recursive = true;
    };
  };

  # Default applications (XDG MIME associations)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browsing
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";

      # Text & code
      "text/plain" = "code.desktop";

      # File manager
      "inode/directory" = "pcmanfm.desktop";

      "application/pdf" = "firefox.desktop";
    };
  };

  # Home files configuration
  home.file = {
    ".tmux.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/tmux/tmux.conf";
    };

    "bin/random-wallpaper" = {
      source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/script/random-wallpaper.sh";
    };

    ".aws/config" = {
      text = ''
        [sso-session nuoa32]
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
  };

  # Services configuration
  services = {
    # Start dunst on login (i3 doesn't autostart it by default in your config)
    dunst.enable = true;
  };

  # X11 session configuration
  xsession = {
    enable = true;
    initExtra = ''
      # Configure reverse/natural scrolling for all mice
      for device in $(xinput list | grep -i mouse | grep -v "Virtual core" | sed 's/.*id=\([0-9]*\).*/\1/'); do
        xinput set-button-map "$device" 1 2 3 5 4 6 7 8 9
      done
    '';
  };

  # Ensure fontconfig is configured at the user level so installed fonts are discoverable
  fonts.fontconfig.enable = true;
}
