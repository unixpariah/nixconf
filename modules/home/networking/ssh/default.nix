{
  pkgs,
  config,
  ...
}:
{
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      compression = false;
      addKeysToAgent = "yes";
      userKnownHostsFile =
        if config.services.impermanence.enable then
          "~/.ssh/persisted/known_hosts"
        else
          "~/.ssh/known_hosts";

      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/S.%r@%h:%p";
      controlPersist = "10m";
    };
  };

  systemd.user.services.derive-public-keys = {
    Unit = {
      Description = "Derive public keys from private SSH keys";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "derive-public-keys" ''
        for file in ~/.ssh/id_*; do
          if [[ ! "$file" =~ \.pub$ ]]; then
            pubfile="''${file}.pub"
            if [[ ! -f "$pubfile" ]]; then
              ${pkgs.openssh}/bin/ssh-keygen -y -f $file > "$pubfile"
              chmod 600 "$pubfile"
            fi
          fi
        done
      '';
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home = {
    persist.directories = [ ".ssh/persisted" ];
    file = {
      ".ssh/config.d/.keep".text = "# Managed by Home Manager";
      ".ssh/sockets/.keep".text = "# Managed by Home Manager";
    };
  };
}
