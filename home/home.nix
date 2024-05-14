{shell, ...}: {
  imports = [
    ./configs/git.nix
    ./configs/qutebrowser.nix
    ./configs/tmux.nix
    ./configs/kitty.nix
    ./configs/firefox.nix
    (
      if shell == "fish"
      then ./configs/fish.nix
      else ./configs/zsh.nix
    )
  ];

  home = {
    username = "unixpariah";
    homeDirectory = "/home/unixpariah";
    stateVersion = "23.11";
    sessionVariables = {
      XDG_DATA_HOME = "$HOME/.local/share";
    };
  };

  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
