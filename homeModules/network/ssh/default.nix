{ ... }:
{
  impermanence.persist.directories = [ ".ssh" ];
  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';

    matchBlocks = {
      "git" = {
        host = "github.com";
        user = "git";
        identityFile = [
          "~/.ssh/id_yubikey"
          "~/.ssh/id_ed25519"
        ];
      };
    };
  };
}
