{ pkgs, ... }:
{
  imports = [
    ./root
    ./yubikey
    ./sops
    ./tpm
  ];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [ "-a exit,always -F arch=b64 -S execve" ];
    };
    pam.services.hyprlock = { };
  };
}
