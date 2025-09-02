{
  lib,
  pkgs,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkgs:
    builtins.elem (lib.getName pkgs) [
      "slack"
      "obsidian"
    ];

  programs = {
    gcloud.enable = true;
    keepassxc.enable = true;
    atuin = {
      enable = true;
    };
    vcs = {
      signingKeyFile = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      email = "100892812+unixpariah@users.noreply.github.com";
    };
    editor = "hx";
    multiplexer = {
      enable = true;
      variant = "tmux";
    };
    vesktop.enable = true;
    firefox.enable = true;
    chromium.enable = true;
    fastfetch.enable = true;
    starship.enable = true;
    zoxide.enable = true;
    direnv.enable = true;
    bottom.enable = true;
  };

  environment = {
    terminal.program = "ghostty";
    outputs = {
      "eDP-1" = {
        position = {
          x = 0;
          y = 1439;
        };
        refresh = 144.0;
        dimensions = {
          width = 1920;
          height = 1080;
        };
      };
      "HDMI-A-1" = {
        position = {
          x = 0;
          y = 0;
        };
        refresh = 180.0;
        dimensions = {
          width = 2560;
          height = 1440;
        };
        scale = 1.25;
      };
    };
  };

  home = {
    persist.directories = [
      "workspace"
      ".yubico"
    ];
    packages = builtins.attrValues { inherit (pkgs) slack figma-linux obsidian; };
  };

  services = {
    impermanence.enable = true;
    yubikey-touch-detector.enable = true;
    #darkfirc.enable = true;
  };

  stylix = {
    enable = true;
    theme = "gruvbox";
    cursor.size = 36;
    opacity.terminal = 0.4;
    fonts = {
      sizes.terminal = 9;
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji-blob-bin;
        name = "Noto Color Emoji";
      };
    };
  };
}
