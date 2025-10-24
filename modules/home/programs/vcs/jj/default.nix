{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.vcs;
  inherit (lib) types;
in
{
  options.programs.vcs.jj = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config.programs.jujutsu = lib.mkIf cfg.jj.enable {
    enable = true;
    settings = {
      user = {
        inherit (cfg) name;
        inherit (cfg) email;
      };

      signing = lib.mkIf (cfg.signingKeyFile != null) {
        behavior = "own";
        backend = "ssh";
        key = cfg.signingKeyFile;
        backends.ssh.allow-singers = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };

      gerrit.default-remote-branch = "main";

      git.push-new-bookmarks = true;

      home.shellAliases.jj = "jj --ignore-immutable";

      ui.movement.edit = true;
    };
  };
}
