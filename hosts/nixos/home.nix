{ config, pkgs, lib, ... }:

let
  username = "dat";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # --- Input Method: fcitx5 + Unikey (Vietnamese Telex) ---
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-unikey ];
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
    fnm
    yarn
    
    # Tools
    vscode

    # Quality-of-life
    direnv
    nix-direnv
    starship
  git

  # Fonts
  fira-code
  ];

  # Zsh setup (+ fnm, corepack)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "z" ];
    };

    initContent = ''
      eval "$(starship init zsh)"

      # fnm: fast Node manager (no HM module required)
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "you@example.com";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Your older .zshrc PATH/env equivalents
  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN  = "$HOME/go/bin";
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
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    # Swap Caps Lock and Escape in GNOME (Wayland-aware)
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:swapescape" ];
    };

    # Theme, dark mode, and UI scale
    "org/gnome/desktop/interface" = {
      accent-color = "teal";
      color-scheme = "prefer-dark";
      text-scaling-factor = 1.25;
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
        "firefox-developer-edition.desktop"
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

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/config/nvim";
    recursive = true;
  };

  # Ensure fontconfig is configured at the user level so installed fonts are discoverable
  fonts.fontconfig.enable = true;
}
