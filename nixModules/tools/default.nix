{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (config) shell nh zoxide username editor term tmux email colorscheme;
in {
  imports =
    [
      (import ./git/home.nix {inherit username email;})
    ]
    ++ (
      if term == "kitty"
      then [(import ./kitty/home.nix {inherit username;})]
      else if term == "foot"
      then [(import ./foot/home.nix {inherit username;})]
      else []
    )
    ++ (
      if tmux == true
      then [(import ./tmux/home.nix {inherit pkgs username shell;})]
      else []
    )
    ++ (
      if nh == true
      then [(import ./nh/default.nix {inherit username pkgs;})]
      else []
    )
    ++ (
      if zoxide == true
      then [(import ./zoxide/default.nix {inherit username shell pkgs;})]
      else []
    )
    ++ (
      if editor == "nvim"
      then [(import ./nvim/default.nix {inherit pkgs inputs username colorscheme;})]
      else []
    );
}
