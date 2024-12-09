{
  pkgs,
  pkgs-stable,
  config,
  ...
}:
{
  services.yubikey-touch-detector = {
    enable = true;
  };
  colorscheme.name = "catppuccin";
  editor = "nvim";
  tmux.enable = true;
  zoxide.enable = true;
  lsd.enable = true;
  man.enable = true;
  bat.enable = true;
  direnv.enable = true;
  nix-index.enable = true;
  seto.enable = true;
  btop.enable = true;
  obs.enable = true;
  email = "oskar.rochowiak@tutanota.com";
  font = "JetBrainsMono Nerd Font";
  sops = {
    secrets = {
      aoc-session = { };
      nixos-access-token-github = { };
    };
    # templates."nix.conf" = {
    #   path = "/home/unixpariah/.config/nix/nix.conf";
    #   content = ''
    #     access-tokens = github.com=${config.sops.placeholder.nixos-access-token-github}
    #   '';
    # };
  };

  home = {
    packages = with pkgs; [
      zathura
      mpv
      ani-cli
      libreoffice
      lazygit
      brightnessctl
      unzip
      gimp
      spotify
      imagemagick
      pkgs-stable.wf-recorder
      nerd-fonts.jetbrains-mono
      jetbrains-mono
    ];
  };
  impermanence = {
    enable = true;
    persist = {
      directories = [
        "workspace"
        "Images"
        "Videos"
        "Documents"
      ];
    };
  };
  gaming = {
    heroic.enable = true;
    steam.enable = true;
    lutris.enable = true;
    minecraft.enable = true;
  };

  discord.enable = true;

  cursor = {
    enable = true;
    themeName = "Banana";
    size = 36;
    package = pkgs.banana-cursor;
  };
  statusBar = {
    enable = true;
    program = "waystatus";
  };
  notifications = {
    enable = true;
    program = "mako";
  };
  screenIdle = {
    lockscreen = {
      enable = true;
      program = "hyprlock";
    };
    idle = {
      enable = true;
      program = "swayidle";
      timeout = {
        lock = 300;
        suspend = 1800;
      };
    };
  };
  launcher = {
    enable = true;
    program = "fuzzel";
  };
  terminal = {
    enable = true;
    program = "foot";
  };
  browser = {
    enable = true;
    program = "zen";
  };
  wallpaper = {
    enable = true;
    program = "ruin";
    path = "nix";
  };

  outputs = {
    "eDP-1" = {
      position = {
        x = 0;
        y = 0;
      };
      refresh = 144.0;
      dimensions = {
        width = 1920;
        height = 1080;
      };
    };
    "HDMI-A-1" = {
      position = {
        x = 1920;
        y = 0;
      };
      refresh = 60.0;
      dimensions = {
        width = 1920;
        height = 1080;
      };
    };
  };
}
