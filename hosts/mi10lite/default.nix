{
  config,
  lib,
  pkgs,
  homeModules,
  inputs,
  rootPath,
  ...
}@configArgs:

let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD cat "${rootPath}/files/keys/id_rsa.tobias.pub" > "${config.user.home}/.ssh/authorized_keys"

    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""
      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort 8022\n" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';

  environment = {
    etcBackupExtension = ".nod-bak";
    motd = null;

    packages =
      [
        (pkgs.writeScriptBin "sshd-start" ''
          #!${pkgs.runtimeShell}

          echo "Starting sshd in non-daemonized way on port 8022"
          ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
        '')
      ]
        builtins.attrValues
        {
          inherit (pkgs)
            diffutils
            findutils
            gawk
            gnugrep
            gnused
            gnutar
            hostname
            man
            ncurses
            procps
            psmisc
            ;
        };
  };

  nix = { inherit (commonConfig.nix) package; };

  system.stateVersion = "25.11";

  terminal.font =
    let
      fontPackage = pkgs.nerdfonts.override { fonts = [ "UbuntuMono" ]; };
      fontPath = "/share/fonts/truetype/NerdFonts/UbuntuMonoNerdFont-Regular.ttf";
    in
    fontPackage + fontPath;

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
