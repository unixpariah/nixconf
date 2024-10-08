{
  pkgs,
  inputs,
  username,
  conf,
}: {
  environment.systemPackages = with pkgs; [
    inputs.ghostty.packages.${system}.default
  ];

  home-manager.users."${username}".home.file.".config/ghostty/config".text = let
    inherit (conf) font;
  in ''
    font-size = 10
    font-family = "${font}"

    window-decoration = false

    background-opacity = 0.0
    background = #000000

    confirm-close-surface = false
  '';
}
