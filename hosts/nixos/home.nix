{ config, pkgs, lib, ... }:

let
  username = "dat";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

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
  };

  # --- Neovim config for vscode-neovim ---
  # Sync the repo folder hosts/nixos/nvim to ~/.config/nvim for clean management
  xdg.configFile."nvim" = {
  source = ./config/nvim;
    recursive = true;
  };
}
