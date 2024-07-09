{
  pkgs,
  inputs,
  wm,
  userConfig,
}: {
  imports = [
    (
      if wm == "Hyprland"
      then (import ./hyprland/default.nix {inherit inputs pkgs userConfig;})
      else if wm == "sway"
      then (import ./sway/default.nix {inherit inputs pkgs userConfig;})
      else []
    )
  ];

  environment = {
    shellAliases.obs = "env -u WAYLAND_DISPLAY obs";
    loginShellInit = ''run_wm'';
    systemPackages = with pkgs; [
      wl-clipboard
      wayland
      obs-studio
      (writeShellScriptBin "run_wm" ''
        if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
        ${(
          if wm == "sway"
          then "exec sway --unsupported-gpu"
          else wm
        )}
        fi
      '')
    ];
  };
}
