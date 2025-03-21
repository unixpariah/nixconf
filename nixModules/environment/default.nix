{
  lib,
  config,
  pkgs,
  system_type,
  inputs,
  ...
}:
{
  imports = [
    ./hyprland
    ./sway
    ./niri
  ];

  config = lib.mkIf (system_type == "desktop") {
  environment = {
    systemPackages = [
      (pkgs.writeShellScriptBin "gamescope-session-uwsm" ''
        #!/usr/bin/env bash
        set -xeuo pipefail

        mangoConfig=(
            cpu_temp
            gpu_temp
            ram
            vram
        )
        mangoVars=(
            MANGOHUD=1
            MANGOHUD_CONFIG="$(IFS=,; echo "''${mangoConfig[*]}")"
        )

        gamescopeArgs=(
            --adaptive-sync 
            --hdr-enabled    
            --mangoapp        
            --rt               
            --steam             
            --expose-wayland     
            --force-grab-cursor   
        )

        steamArgs=(
            -steamdeck
            -steamos3
            -pipewire-dmabuf      
            -tenfoot               
        )

        export "''${mangoVars[@]}"

        gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}" &
        GAMESCOPE_PID=$!

        FINALIZED="I'm here" WAYLAND_DISPLAY=gamescope-0 uwsm finalize

        wait $GAMESCOPE_PID
      '')
    ];
    loginShellInit = lib.mkIf (!config.system.displayManager.enable) ''
      if uwsm check may-start && uwsm select; then
          exec uwsm start default
      fi
    '';
    variables = {
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "0";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };

  xdg = {
    mime.defaultApplications = {
      "inode/directory" = "cosmic-files.desktop";
    };
    terminal-exec.enable = true;
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr = {
        enable = lib.mkForce true;
        settings = {
          screencast = {
            chooser_cmd = "${inputs.seto.packages.${pkgs.system}.default}/bin/seto -f %o";
            chooser_type = "simple";
          };
        };
      };
    };
  };

  programs = {
    xwayland.enable = true;
    uwsm = {
      enable = true;
      waylandCompositors = {
        Hyprland = {
          prettyName = "Hyprland";
          comment = "Compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
        sway = {
          prettyName = "Sway";
          comment = "Compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/sway";
        };
        niri = {
          prettyName = "Niri";
          comment = "Compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
        gamescope = {
          prettyName = "Gamescope";
          comment = "Compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/gamescope-session-uwsm";
        };
      };
    };
  };
  };
}
