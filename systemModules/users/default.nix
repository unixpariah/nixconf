{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The splicing information needed for nativeBuildInputs isn't available
  # on the derivations likely to be used as `cfg.package`.
  # This middle-ground solution ensures *an* sshd can do their basic validation
  # on the configuration.
  validationPackage =
    if pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform then
      cfg.package
    else
      pkgs.buildPackages.openssh;

  # dont use the "=" operator
  settingsFormat =
    let
      # reports boolean as yes / no
      mkValueString =
        with lib;
        v:
        if lib.isInt v then
          toString v
        else if lib.isString v then
          v
        else if true == v then
          "yes"
        else if false == v then
          "no"
        else
          throw "unsupported type ${builtins.typeOf v}: ${(lib.generators.toPretty { }) v}";

      base = pkgs.formats.keyValue {
        mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
      };
      # OpenSSH is very inconsistent with options that can take multiple values.
      # For some of them, they can simply appear multiple times and are appended, for others the
      # values must be separated by whitespace or even commas.
      # Consult either sshd_config(5) or, as last resort, the OpehSSH source for parsing
      # the options at servconf.c:process_server_config_line_depth() to determine the right "mode"
      # for each. But fortunaly this fact is documented for most of them in the manpage.
      commaSeparated = [
        "Ciphers"
        "KexAlgorithms"
        "Macs"
      ];
      spaceSeparated = [
        "AuthorizedKeysFile"
        "AllowGroups"
        "AllowUsers"
        "DenyGroups"
        "DenyUsers"
      ];
    in
    {
      inherit (base) type;
      generate =
        name: value:
        let
          transformedValue = lib.mapAttrs (
            key: val:
            if lib.isList val then
              if lib.elem key commaSeparated then
                lib.concatStringsSep "," val
              else if lib.elem key spaceSeparated then
                lib.concatStringsSep " " val
              else
                throw "list value for unknown key ${key}: ${(lib.generators.toPretty { }) val}"
            else
              val
          ) value;
        in
        base.generate name transformedValue;
    };

  configFile = settingsFormat.generate "sshd.conf-settings" (
    lib.filterAttrs (n: v: v != null) cfg.settings
  );
  sshconf = pkgs.runCommand "sshd.conf-final" { } ''
    cat ${configFile} - >$out <<EOL
    ${cfg.extraConfig}
    EOL
  '';

  cfg = config.services.openssh;
  cfgc = config.programs.ssh;

  nssModulesPath = config.system.nssModules.path;

  userOptions = {

    options.openssh.authorizedKeys = {
      keys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [ ];
        description = ''
          A list of verbatim OpenSSH public keys that should be added to the
          user's authorized keys. The keys are added to a file that the SSH
          daemon reads in addition to the the user's authorized_keys file.
          You can combine the `keys` and
          `keyFiles` options.
          Warning: If you are using `NixOps` then don't use this
          option since it will replace the key required for deployment via ssh.
        '';
        example = [
          "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host"
          "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ foo@bar"
        ];
      };

      keyFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = ''
          A list of files each containing one OpenSSH public key that should be
          added to the user's authorized keys. The contents of the files are
          read at build time and added to a file that the SSH daemon reads in
          addition to the the user's authorized_keys file. You can combine the
          `keyFiles` and `keys` options.
        '';
      };
    };

    options.openssh.authorizedPrincipals = lib.mkOption {
      type = with lib.types; listOf lib.types.singleLineStr;
      default = [ ];
      description = ''
        A list of verbatim principal names that should be added to the user's
        authorized principals.
      '';
      example = [
        "example@host"
        "foo@bar"
      ];
    };

  };

  authKeysFiles =
    let
      mkAuthKeyFile =
        u:
        lib.nameValuePair "ssh/authorized_keys.d/${u.name}" {
          mode = "0444";
          source = pkgs.writeText "${u.name}-authorized_keys" ''
            ${lib.concatStringsSep "\n" u.openssh.authorizedKeys.keys}
            ${lib.concatMapStrings (f: lib.readFile f + "\n") u.openssh.authorizedKeys.keyFiles}
          '';
        };
      usersWithKeys = lib.attrValues (
        lib.flip lib.filterAttrs config.users.users (
          n: u:
          lib.length u.openssh.authorizedKeys.keys != 0 || lib.length u.openssh.authorizedKeys.keyFiles != 0
        )
      );
    in
    lib.listToAttrs (map mkAuthKeyFile usersWithKeys);

  authPrincipalsFiles =
    let
      mkAuthPrincipalsFile =
        u:
        lib.nameValuePair "ssh/authorized_principals.d/${u.name}" {
          mode = "0444";
          text = lib.concatStringsSep "\n" u.openssh.authorizedPrincipals;
        };
      usersWithPrincipals = lib.attrValues (
        lib.flip lib.filterAttrs config.users.users (n: u: lib.length u.openssh.authorizedPrincipals != 0)
      );
    in
    lib.listToAttrs (map mkAuthPrincipalsFile usersWithPrincipals);

in

{
  imports = [
    (lib.mkAliasOptionModuleMD [ "services" "sshd" "enable" ] [ "services" "openssh" "enable" ])
    (lib.mkAliasOptionModuleMD [ "services" "openssh" "knownHosts" ] [ "programs" "ssh" "knownHosts" ])
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "challengeResponseAuthentication" ]
      [ "services" "openssh" "kbdInteractiveAuthentication" ]
    )

    (lib.mkRenamedOptionModule
      [ "services" "openssh" "kbdInteractiveAuthentication" ]
      [ "services" "openssh" "settings" "KbdInteractiveAuthentication" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "passwordAuthentication" ]
      [ "services" "openssh" "settings" "PasswordAuthentication" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "useDns" ]
      [ "services" "openssh" "settings" "UseDns" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "permitRootLogin" ]
      [ "services" "openssh" "settings" "PermitRootLogin" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "logLevel" ]
      [ "services" "openssh" "settings" "LogLevel" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "macs" ]
      [ "services" "openssh" "settings" "Macs" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "ciphers" ]
      [ "services" "openssh" "settings" "Ciphers" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "kexAlgorithms" ]
      [ "services" "openssh" "settings" "KexAlgorithms" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "gatewayPorts" ]
      [ "services" "openssh" "settings" "GatewayPorts" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "openssh" "forwardX11" ]
      [ "services" "openssh" "settings" "X11Forwarding" ]
    )
  ];

  ###### interface

  options = {
    services.openssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable the OpenSSH secure shell daemon, which
          allows secure remote logins.
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = config.programs.ssh.package;
        defaultText = lib.literalExpression "programs.ssh.package";
        description = "OpenSSH package to use for sshd.";
      };

      startWhenNeeded = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set, {command}`sshd` is socket-activated; that
          is, instead of having it permanently running as a daemon,
          systemd will start an instance for each incoming connection.
        '';
      };

      allowSFTP = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable the SFTP subsystem in the SSH daemon.  This
          enables the use of commands such as {command}`sftp` and
          {command}`sshfs`.
        '';
      };

      sftpServerExecutable = lib.mkOption {
        type = lib.types.str;
        example = "internal-sftp";
        description = ''
          The sftp server executable.  Can be a path or "internal-sftp" to use
          the sftp server built into the sshd binary.
        '';
      };

      sftpFlags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        example = [
          "-f AUTHPRIV"
          "-l INFO"
        ];
        description = ''
          Commandline flags to add to sftp-server.
        '';
      };

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 22 ];
        description = ''
          Specifies on which ports the SSH daemon listens.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to automatically open the specified ports in the firewall.
        '';
      };

      listenAddresses = lib.mkOption {
        type =
          with lib.types;
          listOf (submodule {
            options = {
              addr = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  Host, IPv4 or IPv6 address to listen to.
                '';
              };
              port = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
                description = ''
                  Port to listen to.
                '';
              };
            };
          });
        default = [ ];
        example = [
          {
            addr = "192.168.3.1";
            port = 22;
          }
          {
            addr = "0.0.0.0";
            port = 64022;
          }
        ];
        description = ''
          List of addresses and ports to listen on (ListenAddress directive
          in config). If port is not specified for address sshd will listen
          on all ports specified by `ports` option.
          NOTE: this will override default listening on all local addresses and port 22.
          NOTE: setting this option won't automatically enable given ports
          in firewall configuration.
        '';
      };

      hostKeys = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [
          {
            type = "rsa";
            bits = 4096;
            path = "/etc/ssh/ssh_host_rsa_key";
          }
          {
            type = "ed25519";
            path = "/etc/ssh/ssh_host_ed25519_key";
          }
        ];
        example = [
          {
            type = "rsa";
            bits = 4096;
            path = "/etc/ssh/ssh_host_rsa_key";
            rounds = 100;
            openSSHFormat = true;
          }
          {
            type = "ed25519";
            path = "/etc/ssh/ssh_host_ed25519_key";
            rounds = 100;
            comment = "key comment";
          }
        ];
        description = ''
          NixOS can automatically generate SSH host keys.  This option
          specifies the path, type and size of each key.  See
          {manpage}`ssh-keygen(1)` for supported types
          and sizes.
        '';
      };

      banner = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Message to display to the remote user before authentication is allowed.
        '';
      };

      authorizedKeysFiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Specify the rules for which files to read on the host.

          This is an advanced option. If you're looking to configure user
          keys, you can generally use [](#opt-users.users._name_.openssh.authorizedKeys.keys)
          or [](#opt-users.users._name_.openssh.authorizedKeys.keyFiles).

          These are paths relative to the host root file system or home
          directories and they are subject to certain token expansion rules.
          See AuthorizedKeysFile in man sshd_config for details.
        '';
      };

      authorizedKeysInHomedir = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Enables the use of the `~/.ssh/authorized_keys` file.

          Otherwise, the only files trusted by default are those in `/etc/ssh/authorized_keys.d`,
          *i.e.* SSH keys from [](#opt-users.users._name_.openssh.authorizedKeys.keys).
        '';
      };

      authorizedKeysCommand = lib.mkOption {
        type = lib.types.str;
        default = "none";
        description = ''
          Specifies a program to be used to look up the user's public
          keys. The program must be owned by root, not writable by group
          or others and specified by an absolute path.
        '';
      };

      authorizedKeysCommandUser = lib.mkOption {
        type = lib.types.str;
        default = "nobody";
        description = ''
          Specifies the user under whose account the AuthorizedKeysCommand
          is run. It is recommended to use a dedicated user that has no
          other role on the host than running authorized keys commands.
        '';
      };

      settings = lib.mkOption {
        description = "Configuration for `sshd_config(5)`.";
        default = { };
        example = lib.literalExpression ''
          {
            UseDns = true;
            PasswordAuthentication = false;
          }
        '';
        type = lib.types.submodule (
          { name, ... }:
          {
            freeformType = settingsFormat.type;
            options = {
              AuthorizedPrincipalsFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "none"; # upstream default
                description = ''
                  Specifies a file that lists principal names that are accepted for certificate authentication. The default
                  is `"none"`, i.e. not to use	a principals file.
                '';
              };
              LogLevel = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "QUIET"
                    "FATAL"
                    "ERROR"
                    "INFO"
                    "VERBOSE"
                    "DEBUG"
                    "DEBUG1"
                    "DEBUG2"
                    "DEBUG3"
                  ]
                );
                default = "INFO"; # upstream default
                description = ''
                  Gives the verbosity level that is used when logging messages from {manpage}`sshd(8)`. Logging with a DEBUG level
                  violates the privacy of users and is not recommended.
                '';
              };
              UsePAM = lib.mkEnableOption "PAM authentication" // {
                default = true;
                type = lib.types.nullOr lib.types.bool;
              };
              UseDns = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                # apply if cfg.useDns then "yes" else "no"
                default = false;
                description = ''
                  Specifies whether {manpage}`sshd(8)` should look up the remote host name, and to check that the resolved host name for
                  the remote IP address maps back to the very same IP address.
                  If this option is set to no (the default) then only addresses and not host names may be used in
                  ~/.ssh/authorized_keys from and sshd_config Match Host directives.
                '';
              };
              X11Forwarding = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = false;
                description = ''
                  Whether to allow X11 connections to be forwarded.
                '';
              };
              PasswordAuthentication = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = true;
                description = ''
                  Specifies whether password authentication is allowed.
                '';
              };
              PermitRootLogin = lib.mkOption {
                default = "prohibit-password";
                type = lib.types.nullOr (
                  lib.types.enum [
                    "yes"
                    "without-password"
                    "prohibit-password"
                    "forced-commands-only"
                    "no"
                  ]
                );
                description = ''
                  Whether the root user can login using ssh.
                '';
              };
              KbdInteractiveAuthentication = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = true;
                description = ''
                  Specifies whether keyboard-interactive authentication is allowed.
                '';
              };
              GatewayPorts = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "no";
                description = ''
                  Specifies whether remote hosts are allowed to connect to
                  ports forwarded for the client.  See
                  {manpage}`sshd_config(5)`.
                '';
              };
              KexAlgorithms = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = [
                  "mlkem768x25519-sha256"
                  "sntrup761x25519-sha512"
                  "sntrup761x25519-sha512@openssh.com"
                  "curve25519-sha256"
                  "curve25519-sha256@libssh.org"
                  "diffie-hellman-group-exchange-sha256"
                ];
                description = ''
                  Allowed key exchange algorithms

                  Uses the lower bound recommended in both
                  <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
                  and
                  <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
                '';
              };
              Macs = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = [
                  "hmac-sha2-512-etm@openssh.com"
                  "hmac-sha2-256-etm@openssh.com"
                  "umac-128-etm@openssh.com"
                ];
                description = ''
                  Allowed MACs

                  Defaults to recommended settings from both
                  <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
                  and
                  <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
                '';
              };
              StrictModes = lib.mkOption {
                type = lib.types.nullOr (lib.types.bool);
                default = true;
                description = ''
                  Whether sshd should check file modes and ownership of directories
                '';
              };
              Ciphers = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = [
                  "chacha20-poly1305@openssh.com"
                  "aes256-gcm@openssh.com"
                  "aes128-gcm@openssh.com"
                  "aes256-ctr"
                  "aes192-ctr"
                  "aes128-ctr"
                ];
                description = ''
                  Allowed ciphers

                  Defaults to recommended settings from both
                  <https://stribika.github.io/2015/01/04/secure-secure-shell.html>
                  and
                  <https://infosec.mozilla.org/guidelines/openssh#modern-openssh-67>
                '';
              };
              AllowUsers = lib.mkOption {
                type = with lib.types; nullOr (listOf str);
                default = null;
                description = ''
                  If specified, login is allowed only for the listed users.
                  See {manpage}`sshd_config(5)` for details.
                '';
              };
              DenyUsers = lib.mkOption {
                type = with lib.types; nullOr (listOf str);
                default = null;
                description = ''
                  If specified, login is denied for all listed users. Takes
                  precedence over [](#opt-services.openssh.settings.AllowUsers).
                  See {manpage}`sshd_config(5)` for details.
                '';
              };
              AllowGroups = lib.mkOption {
                type = with lib.types; nullOr (listOf str);
                default = null;
                description = ''
                  If specified, login is allowed only for users part of the
                  listed groups.
                  See {manpage}`sshd_config(5)` for details.
                '';
              };
              DenyGroups = lib.mkOption {
                type = with lib.types; nullOr (listOf str);
                default = null;
                description = ''
                  If specified, login is denied for all users part of the listed
                  groups. Takes precedence over
                  [](#opt-services.openssh.settings.AllowGroups). See
                  {manpage}`sshd_config(5)` for details.
                '';
              };
              # Disabled by default, since pam_motd handles this.
              PrintMotd = lib.mkEnableOption "printing /etc/motd when a user logs in interactively" // {
                type = lib.types.nullOr lib.types.bool;
              };
            };
          }
        );
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Verbatim contents of {file}`sshd_config`.";
      };

      moduliFile = lib.mkOption {
        example = "/etc/my-local-ssh-moduli;";
        type = lib.types.path;
        description = ''
          Path to `moduli` file to install in
          `/etc/ssh/moduli`. If this option is unset, then
          the `moduli` file shipped with OpenSSH will be used.
        '';
      };

    };

    users.users = lib.mkOption { type = with lib.types; attrsOf (submodule userOptions); };
  };
}
