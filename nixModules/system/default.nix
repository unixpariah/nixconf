{
  conf,
  pkgs,
  lib,
  std,
}: let
  inherit (conf) username virtualization zram;
  inherit (lib) optional;
in {
  imports =
    [
      (
        if conf.boot.loader == "systemd-boot"
        then (import ./bootloader/systemd-boot)
        else (import ./bootloader/grub)
      )
      (
        if conf ? shell && conf.shell == "fish"
        then (import ./shell/fish {inherit conf pkgs;})
        else if conf ? shell && conf.shell == "zsh"
        then (import ./shell/zsh {inherit conf pkgs std;})
        else (import ./shell/bash {inherit username pkgs;})
      )
    ]
    ++ optional virtualization (import ./virtualization {inherit username pkgs;})
    ++ optional zram ./zram;
}
