{
  lib,
  pkgs,
  config,
  inputs,
  systemUsers,
  ...
}:
let
  cfg = config.services.impermanence;
  inherit (lib) types;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options = {
    services.impermanence = {
      enable = lib.mkEnableOption "Enable impermanence";
      mountPoint = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = "cryptid";
      };
      vg = lib.mkOption { type = lib.types.str; };
    };

    environment.persist = {
      users = {
        files = lib.mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        directories = lib.mkOption {
          type = types.listOf types.anything;
          default = [ ];
        };
      };
      directories = lib.mkOption {
        type = types.listOf types.anything;
        default = [ ];
      };
      files = lib.mkOption {
        type = types.listOf types.anything;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = {
      systemd.services = {
        btrfs-rollback = lib.mkIf (config.system.fileSystem == "btrfs") {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = [ "initrd.target" ];
          after = [
            "systemd-cryptsetup@crypted-main.service"
            "systemd-cryptsetup@crypted-extra.service"
            "lvm2-activation-early.service"
          ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt
            # We first mount the btrfs root to /mnt
            # so we can manipulate btrfs subvolumes.
            mount -t btrfs -o subvol=/ /dev/mapper/root_vg-root /mnt
            # While we're tempted to just delete /root and create
            # a new snapshot from /root-blank, /root is already
            # populated at this point with a number of subvolumes,
            # which makes `btrfs subvolume delete` fail.
            # So, we remove them first.
            #
            # /root contains subvolumes:
            # - /root/var/lib/portables
            # - /root/var/lib/machines
            #
            # I suspect these are related to systemd-nspawn, but
            # since I don't use it I'm not 100% sure.
            # Anyhow, deleting these subvolumes hasn't resulted
            # in any issues so far, except for fairly
            # benign-looking errors from systemd-tmpfiles.
            btrfs subvolume list -o /mnt/root |
              cut -f9 -d' ' |
              while read -r subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting /root subvolume..." &&
              btrfs subvolume delete /mnt/root
            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/root-blank /mnt/root
            # Once we're done rolling back to a blank snapshot,
            # we can unmount /mnt and continue on the boot process.
            umount /mnt
          '';
        };

        zfs-rollback = lib.mkIf (config.system.fileSystem == "zfs") {
          description = "Rollback ZFS datasets to a pristine state";
          wantedBy = [ "initrd.target" ];
          after = [ "zfs-import-zroot.service" ];
          before = [ "sysroot.mount" ];
          path = [ pkgs.zfs ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r zroot/local/root@blank
          '';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint}/home 0777 root root -"
    ]
    ++ (
      systemUsers
      |> builtins.attrNames
      |> lib.concatMap (user: [ "d ${cfg.mountPoint}/home/${user} 0700 ${user} users -" ])
    );

    programs.fuse.userAllowOther = true;

    environment.persistence."${cfg.mountPoint}/system" = {
      hideMounts = true;
      directories = [
        "/usr/systemd-placeholder"
        "/var/lib/systemd/coredump"
        "/var/lib/nixos"
        "/var/lib/journal"
        {
          directory = "/var/lib/nixconf";
          user = "root";
          group = "wheel";
          mode = "0775";
        }
      ]
      ++ config.environment.persist.directories;
      inherit (config.environment.persist) files;

      users = systemUsers |> lib.mapAttrs (name: value: config.environment.persist.users);
    };

    systemd.services.activate-home-manager = {
      description = "Activate home manager";
      wantedBy = [ "default.target" ];
      requiredBy = [ "systemd-user-sessions.service" ];
      after = [ "sops-install-secrets.service" ];
      before = [ "systemd-user-sessions.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      environment.PATH = lib.mkForce "${pkgs.nix}/bin:${pkgs.git}/bin:${pkgs.home-manager}/bin:${pkgs.sudo}/bin:${pkgs.coreutils}/bin:$PATH";
      script = lib.concatMapStrings (user: ''
        chown -R ${user}:users /home/${user}
        if [ -L "${cfg.mountPoint}/home/${user}/.local/state/nix/profiles/home-manager" ]; then
          HOME_MANAGER_BACKUP_EXT="bak" sudo -u ${user} ${cfg.mountPoint}/home/${user}/.local/state/nix/profiles/home-manager/activate
        fi
      '') (lib.attrNames systemUsers);
    };
  };
}
