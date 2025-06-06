{ lib, config, ... }:
{
  imports = [
    ./bootloader
    ./virtualisation
    ./impermanence
    ./ydotool
    ./gc
    ./displayManager
  ];

  options.system.fileSystem = lib.mkOption {
    type = lib.types.enum [
      "btrfs"
      "ext4"
      "zfs"
    ];
  };
}
