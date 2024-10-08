{
  inputs,
  username,
  pkgs,
  hostname,
  std,
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    secrets.password.neededForUsers = true;
    defaultSopsFile = ../../../hosts/${hostname}/secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      sshKeyPaths = ["${std.dirs.home}/.ssh/id_ed25519"];
      keyFile = "${std.dirs.home}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "opensops" ''
      sops "$FLAKE/hosts/${hostname}/secrets/secrets.yaml"
    '')
    sops
  ];
}
