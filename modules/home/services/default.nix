{ inputs, profile, ... }:
{
  imports = [
    inputs.sysnotifier.homeManagerModules.default
    ./impermanence
    ./yubikey-touch-detector
    ./ngrok
    ./cliphist
    ./gc
    ./sccache
  ];

  services = {
    udiskie.enable = profile == "desktop";
    sysnotifier.enable = profile == "desktop";
  };
}
