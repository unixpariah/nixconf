{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./configs/fish.nix
    ./configs/sway.nix
  ];
}