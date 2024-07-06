{
  userConfig,
  pkgs,
  lib,
  config,
  helpers,
  inputs,
}: let
  inherit (userConfig) username email colorscheme font;
  shell = lib.mkDefault (
    if lib.hasAttr "shell" userConfig
    then userConfig.shell
    else "bash"
  );
in {
  imports =
    [
      (import ./git/home.nix {inherit username;})
      (import ./msmtp/default.nix {inherit config username email lib;})
    ]
    ++ (
      if helpers.checkAttribute "terminal" "kitty"
      then [(import ./kitty/home.nix {inherit username font;})]
      else if helpers.checkAttribute "terminal" "foot"
      then [(import ./foot/home.nix {inherit username font;})]
      else []
    )
    ++ (
      if helpers.checkAttribute "editor" "nvim"
      then [(import ./nvim/default.nix {inherit pkgs username colorscheme;})]
      else []
    )
    ++ (
      if helpers.isDisabled "tmux"
      then []
      else [(import ./tmux/home.nix {inherit pkgs username shell colorscheme;})]
    )
    ++ (
      if helpers.isDisabled "seto"
      then []
      else [(import ./seto/home.nix {inherit colorscheme username font pkgs inputs;})]
    )
    ++ (
      if helpers.isDisabled "nh"
      then []
      else [(import ./nh/default.nix {inherit username pkgs;})]
    )
    ++ (
      if helpers.isDisabled "zoxide"
      then []
      else [(import ./zoxide/default.nix {inherit username shell pkgs;})]
    )
    ++ (
      if helpers.isDisabled "man"
      then []
      else [(import ./man/default.nix {inherit pkgs;})]
    )
    ++ (
      if helpers.isDisabled "lsd"
      then []
      else [(import ./lsd/default.nix {inherit username;})]
    )
    ++ (
      if helpers.isDisabled "bat"
      then []
      else [(import ./bat/default.nix {inherit username;})]
    )
    ++ (
      if helpers.isDisabled "direnv"
      then []
      else [(import ./direnv/default.nix {inherit username shell;})]
    );
}
