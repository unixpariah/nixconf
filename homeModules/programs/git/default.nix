{ config, lib, ... }:
let
  cfg = config.programs.git;
in
{
  options.programs.git = {
    identityFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
    };
    signingKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    email = lib.mkOption { type = lib.types.nullOr lib.types.str; };
  };

  config = {
    programs = {
      ssh.matchBlocks = lib.mkIf (cfg.identityFile != null) {
        "git" = {
          host = "github.com";
          user = "git";
          forwardAgent = true;
          identitiesOnly = true;
          inherit (cfg) identityFile;
        };
      };

      git = {
        enable = true;
        userName = config.home.username;
        userEmail = cfg.email;

        signing = lib.mkIf (cfg.signingKeyFile != null) {
          key = cfg.signingKeyFile;
          format = "ssh";
          signByDefault = true;
        };

        aliases = {
          rev = "review --no-rebase --reviewers ${cfg.userName}";
        };

        extraConfig = {
          init.defaultBranch = "master";
          #url = {
          #"ssh://git@github.com" = {
          #insteadOf = "https://github.com";
          #};
          #"ssh://git@gitlab.com" = {
          #insteadOf = "https://gitlab.com";
          #};
          #};
          gpg = {
            format = "ssh";
            ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
          };
          user.signing.key = lib.mkIf (cfg.signingKeyFile != null) cfg.signingKeyFile;
        };
      };

      jujutsu = {
        enable = true;
        settings = {
          ui.paginate = "never";
          user = {
            name = config.home.username;
            inherit (cfg) email;
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = lib.mkIf (cfg.signingKeyFile != null) cfg.signingKeyFile;
            backends.ssh.allow-singers = "${config.home.homeDirectory}/.ssh/allowed_signers";
          };
        };
      };
    };
  };
}
