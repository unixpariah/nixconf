{ username, std, pkgs, pkgs-stable, ... }: {
  imports = [ ./disko.nix ./gpu.nix ./hardware-configuration.nix ];

  host = {
    impermanence = {
      enable = true;
      persist = {
        directories =
          [ "/var/log" "/var/lib/nixos" "/var/lib/systemd/coredump" ];
        files = [ ];
      };
    };
    users = {
      "unixpariah" = {
        enable = true;
        root.enable = true;
      };
    };
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
        height = 1920;
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
        height = 1920;
      };
    };
  };

  power.enable = true;
  boot = {
    program = "grub";
    legacy = false;
  };
  wireless.enable = true;
  bluetooth.enable = true;
  audio.enable = true;
  zram.enable = true;

  sops = {
    enable = true;
    managePassword = true;
    secrets.nixos-access-token-github = {
      owner = "${username}";
      path = "${std.dirs.home}/.config/nix/nix.conf";
    };
  };
  colorscheme.name = "catppuccin";
  font = "JetBrainsMono Nerd Font";
  email = "oskar.rochowiak@tutanota.com";
  editor = "nvim";
  shell = "fish";
  cursor = {
    enable = true;
    name = "banana";
    themeName = "Banana";
    size = 40;
  };
  statusBar = {
    enable = true;
    program = "waystatus";
  };
  notifications = {
    enable = true;
    program = "mako";
  };

  # This is a TODO
  screenIdle = {
    idle = {
      enable = true;
      program = "swayidle";
      timeout = {
        lock = 300;
        suspend = 1800;
      };
    };
    lockscreen = {
      enable = true;
      program = "hyprlock";
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
  tmux.enable = true;
  nh.enable = true;
  zoxide.enable = true;
  lsd.enable = true;
  man.enable = true;
  bat.enable = true;
  direnv.enable = true;
  nix-index.enable = true;
  ydotool.enable = true;
  seto.enable = true;
  virtualisation.enable = true;
  btop.enable = true;
  obs.enable = true;
  gaming = {
    heroic.enable = true;
    steam.enable = true;
    lutris.enable = true;
    minecraft.enable = true;
  };
  wallpaper = {
    enable = true;
    program = "ruin";
    path = "nix";
  };
  impermanence.persist-home = {
    directories =
      [ "workspace" "Images" "Videos" ".config/discord" "Documents" ];
    files = [ ];
  };

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    zathura
    mpv
    ani-cli
    libreoffice
    lazygit
    discord
    brightnessctl
    unzip
    gimp
    spotify
    imagemagick
    pkgs-stable.wf-recorder
  ];

  fonts.packages = with pkgs; [ jetbrains-mono font-awesome nerdfonts ];

  system.stateVersion = "24.05";
}
