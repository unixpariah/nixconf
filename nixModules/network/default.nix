{
  config,
  pkgs,
  ...
}: let
  inherit (config) wireless hostname username;
in {
  imports =
    [
      (import ./ssh/default.nix {inherit username;})
    ]
    ++ (
      if wireless == true
      then [(import ./wireless/default.nix {inherit pkgs hostname;})]
      else []
    );
}
