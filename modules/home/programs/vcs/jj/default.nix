{
  config,
  lib,
  pkgs,
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
    package = lib.mkPackageOption pkgs "jujutsu" { };
  };

  config.programs.jujutsu = lib.mkIf cfg.jj.enable {
    enable = true;
    settings = {
      user = {
        name = lib.mkDefault config.home.username;
        inherit (cfg) email;
      };

      signing = lib.mkIf (cfg.signingKeyFile != null) {
        behavior = "own";
        backend = "ssh";
        key = cfg.signingKeyFile;
        backends.ssh.allow-singers = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };

      git.push-new-bookmarks = true;

      # True freedom, fully mutable commits
      revset-aliases."immutable_heads()" = "none()";

      ui.movement.edit = true;

      templates = {
        commit_trailers = ''
          if(self.author().email() == "${cfg.email}" &&
            !trailers.contains_key("Change-Id"),
            format_gerrit_change_id_trailer(self)
          )
        '';
      };

      aliases = {
        review = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            set -euo pipefail

            WIP_FLAG=""
            INPUT=""

            while [[ $# -gt 0 ]]; do
              case $1 in
                -w|--wip|--work-in-progress)
                  WIP_FLAG="%wip"
                  shift
                  ;;
                *)
                  INPUT="$1"
                  shift
                  ;;
              esac
            done

            # Default to "@" if no input specified
            INPUT=''${INPUT:-"@"}

            HASH=$(${cfg.jj.package}/bin/jj log -r "''${INPUT}" -T commit_id --no-graph)
            HASHINFO=$(${cfg.git.package}/bin/git log -n 1 ''${HASH} --oneline --color=always)
            echo "Pushing from commit ''${HASHINFO}"
            BRANCH=$(${cfg.git.package}/bin/git branch --list main master | tr -d ' *')

            ${cfg.git.package}/bin/git push origin "''${HASH}":refs/for/"''${BRANCH}''${WIP_FLAG}"

            [ "''${INPUT}" = "@" ] && ${cfg.jj.package}/bin/jj new || true
          ''
          ""
        ];
      };
    };
  };
}
