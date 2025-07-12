{ inputs, pkgs, ... }:
{
  imports = [ ./access-tokens ];

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      substituters = [
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-substituters = [
        "https://cache.garnix.io"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
