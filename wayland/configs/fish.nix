{pkgs, ...}: {
  programs.fish = {
    loginShellInit = ''
      if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
          Hyprland
      end
    '';

    shellAliases = {
      obs = "env -u WAYLAND_DISPLAY obs";
    };
  };
}
