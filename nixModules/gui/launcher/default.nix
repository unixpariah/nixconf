{ conf, lib }: {
  options.launcher = {
    enable = lib.mkEnableOption "Enable launcher";
    program = lib.mkOption { type = lib.types.enum [ "fuzzel" ]; };
  };

  imports = [ (import ./fuzzel { inherit conf lib; }) ];
}
