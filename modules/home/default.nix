{
  pkgs,
  lib,
  inputs,
  config,
  platform,
  ...
}:
{
  imports = [
    ./nix
    ./nixpkgs
    ./environment
    ./programs
    ./security
    ./networking
    ./services
    ./specialisation.nix
    ../theme
    inputs.mox-flake.homeManagerModules.moxidle
    inputs.mox-flake.homeManagerModules.moxnotify
    inputs.mox-flake.homeManagerModules.moxctl
    inputs.mox-flake.homeManagerModules.moxpaper
  ];

  xdg.configFile."environment.d/envvars.conf" = lib.mkIf (platform == "non-nixos") {
    text = ''
      PATH="${config.home.homeDirectory}/.nix-profile/bin:$PATH";
    '';
  };

  nixpkgs.overlays = import ../overlays inputs config ++ import ../lib config;

  nixGL.packages = inputs.nixGL.packages;

  home.activation.switch-to-specialisation =
    lib.mkIf (config.specialisation != { } && platform != "non-nixos")
      (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Function to log to both stdout and journald
          log() {
            echo "$@"
            echo "$@" | ${pkgs.systemd}/bin/systemd-cat -t home-manager-specialisation -p info
          }

          log "=== Running switch-to-specialisation activation ==="

          if [ -f /etc/specialisation ]; then
            SPECIALISATION="$(tr -d '[:space:]' < /etc/specialisation)"
            log "Found specialisation file: /etc/specialisation"
            log "Specialisation value: '$SPECIALISATION'"
          else
            log "No specialisation file found at /etc/specialisation"
            SPECIALISATION=""
          fi

          log "Getting latest home-manager generation..."
          GEN_PATH="$(${pkgs.home-manager}/bin/home-manager generations | head -1 | ${pkgs.ripgrep}/bin/rg -o '/[^ ]*')"
          log "Latest generation path: $GEN_PATH"

          if [ -n "$SPECIALISATION" ] && [ -x "$GEN_PATH/specialisation/$SPECIALISATION/activate" ]; then
            log "Activating specialisation: $SPECIALISATION"
            log "Activation script: $GEN_PATH/specialisation/$SPECIALISATION/activate"
            "$GEN_PATH/specialisation/$SPECIALISATION/activate" 2>&1 | ${pkgs.systemd}/bin/systemd-cat -t home-manager-specialisation -p info
            log "Specialisation activation complete"
          else
            if [ -n "$SPECIALISATION" ]; then
              log "Warning: Specialisation '$SPECIALISATION' not found or not executable"
            fi
            log "Activating default configuration"
            log "Activation script: $GEN_PATH/activate"
            "$GEN_PATH/activate" 2>&1 | ${pkgs.systemd}/bin/systemd-cat -t home-manager-specialisation -p info
            log "Default activation complete"
          fi

          log "=== switch-to-specialisation activation completed ==="
        ''
      );

  home = {
    persist.directories = [ ".local/state/syncthing" ];
    packages = [
      (pkgs.writeShellScriptBin "nb" ''
        command "$@" > /dev/null 2>&1 &
        disown
      '')
    ];
    stateVersion = "25.11";
  };
}
