{
  config,
  pkgs,
  ...
}: let
  inherit (config) shell grub username virtualization;
in {
  imports =
    [
      (
        if grub == true
        then ./bootloader/grub/default.nix
        else ./bootloader/systemd-boot/default.nix
      )
      (
        if shell == "fish"
        then (import ./shell/fish/default.nix {inherit username pkgs;})
        else if shell == "zsh"
        then (import ./shell/zsh/default.nix {inherit username pkgs;})
        else
          (
            import ./shell/bash/default.nix {inherit username pkgs;}
          )
      )
    ]
    ++ (
      if virtualization == true
      then [(import ./virtualization/default.nix {inherit username;})]
      else []
    );
}