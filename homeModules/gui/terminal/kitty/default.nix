{ config, lib, ... }:
let
  inherit (config) font;
in
{
  config = lib.mkIf (config.terminal.enable && config.terminal.program == "kitty") {
    programs.kitty = {
      enable = true;
      font.name = "${font}";
      font.size = 9;
      keybindings = {
        "alt+v" = "paste_from_clipboard";
        "alt+c" = "copy_to_clipboard";
      };
      settings = {
        "background_opacity" = 0;
        "confirm_os_window_close" = 0;
      };
    };
  };
}
