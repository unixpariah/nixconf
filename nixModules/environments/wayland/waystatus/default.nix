{
  username,
  colorscheme,
  font,
}: let
  colors =
    if colorscheme == "lackluster"
    then ["#000000" "175, 175, 175, 175"]
    else if colorscheme == "catppuccin"
    then ["#ffffff" "20, 15, 33, 1"]
    else if colorscheme == "gruvbox"
    then ["#EBDBB2" "124, 111, 100"]
    else [];
  getColor = index: "${builtins.elemAt colors index}";
in {
  home-manager.users."${username}".home.file = {
    ".config/waystatus/style.css" = {
      text = ''
        * {
            font-family: "${font}";
            font-size: 16px;
            font-weight: bold;
            color: ${getColor 0};
            background-color: rgba(0, 0, 0, 0);
            margin-bottom: 10px;
        }

        backlight {
            margin-left: 25px;
            margin-right: 10px;
        }

        audio {
            margin-right: 25px;
        }

        cpu {
            margin-right: 25px;
        }

        memory {
            margin-right: 10px;
        }

        workspaces {
            margin-left: 35px;
        }

        network {
            margin-right: 25px;
        }

        title {
            margin-right: 25px;
        }

        persistant_workspaces {
            letter-spacing: 10px;
            margin-left: 35px;
        }
      '';
    };
    ".config/waystatus/config.toml" = {
      text = ''
        unkown = "N/A"
        background = [${getColor 1}]
        layer = "bottom"
        topbar = true
        height = 40

        [[modules.left]]
        command.Workspaces = { active = " ", inactive = " " }

        [[modules.center]]
        command.Custom = { command = "date +%H:%M", name = "date", event = { TimePassed = 60000 }, formatting = " %s" }

        [[modules.right]]
        command.Custom = { command = "iwgetid -r", name = "network", event = { TimePassed = 10000 }, formatting = "  %s" }

        [[modules.right]]
        command.Cpu = { interval = 5000, formatting = "󰍛 %s%" }

        [[modules.right]]
        command.Memory = { memory_opts = "PercUsed", interval = 5000, formatting = "󰍛 %s%" }

        [[modules.right]]
        command.Audio = { formatting = "%c %s%", icons = ["", "", "󰕾", ""] }

        [[modules.right]]
        command.Backlight = { formatting = "%c %s%", icons = ["", "", "", "", "", "", "", "", ""] }

        [[modules.right]]
        command.Battery = { interval = 5000, formatting = "%c %s%", icons = ["󰁺" ,"󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"] }
      '';
    };
  };
}