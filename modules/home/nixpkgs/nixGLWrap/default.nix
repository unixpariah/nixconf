# Helper for wrapping packages with nixGL
#
# Usage:
# nixpkgs.config.nixGLWrap = [ "package1" "package2" ];
{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.nixGLWrap;
  inherit (lib) types;
in
{
  options.nixGLWrap = lib.mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  config = {
    nixGL = {
      packages = inputs.nixGL.packages;
      vulkan.enable = true;
    };

    nixpkgs.overlays = lib.mkAfter [
      (
        _: prev:
        let
          wrapAttrs = lib.listToAttrs (
            cfg
            |> lib.map (name: {
              name = name;
              value = prev.${name};
            })
          );
        in
        lib.attrsets.mapAttrs (_: pkg: config.lib.nixGL.wrap pkg) wrapAttrs
      )

    ];
  };
}
