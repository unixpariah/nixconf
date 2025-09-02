{ ... }:
{
  programs.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = [ ];
  };
}
