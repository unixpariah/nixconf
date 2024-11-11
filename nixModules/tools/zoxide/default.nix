{ config, lib, username, ... }: {
  options.zoxide.enable = lib.mkEnableOption "Enable zoxide";

  config = lib.mkIf config.zoxide.enable {
    home-manager.users."${username}" = {
      programs.zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
      };
    };

    impermanence.persist-home.directories =
      [ ".cache/zoxide" ".local/share/zoxide" ];
  };
}
