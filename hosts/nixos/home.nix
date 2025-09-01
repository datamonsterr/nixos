{ config, pkgs, lib, ... }:

let
  username = "dat";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ---- Developer Toolchain (user-scoped) ----

  # Java (OpenJDK 11)
  home.packages = with pkgs; [
    jdk11
    go
    python313
    # Node package managers; installed directly (fast + reproducible)
    pnpm
    yarn
    # Useful extras
    direnv
    nix-direnv
    starship
  ];

  # Node via nvm (lets you switch versions freely)
  programs.nvm = {
    enable = true;
    # Provide a default Node so new shells "just work"
    # You can change to nodejs_20 or nodejs_18 if you need older LTS
    nodejs = pkgs.nodejs_22;
    # Optional: pre-create aliases or default version
    # profile = "lts/*";
  };

  # direnv + nix-direnv for per-project envs
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Zsh + Starship prompt
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      eval "$(starship init zsh)"
      # If you often use Node via nvm, ensure nvm is loaded for shells
      if [ -s "$HOME/.nvm/nvm.sh" ]; then
        . "$HOME/.nvm/nvm.sh"
      fi
      # Enable corepack (lets yarn/pnpm be managed by Node if you prefer)
      if command -v corepack >/dev/null 2>&1; then
        corepack enable || true
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "datamonsterr";
    userEmail = "phamthanhdat17092004@gmail.com";
  };
}
