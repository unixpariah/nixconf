{
  pkgs,
  username,
  shell,
}: {
  environment = {
    systemPackages = with pkgs; [zoxide];
    shellAliases = {cd = "z";};
  };
  home-manager.users."${username}".programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
