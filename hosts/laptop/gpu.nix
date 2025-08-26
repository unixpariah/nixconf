{ config, ... }:
{
  #nixpkgs.config.cudaSupport = true;

  hardware = {
    nvidia = {
      nvidiaSettings = false;
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };

      dynamicBoost.enable = true;
      forceFullCompositionPipeline = true;

      open = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:0:1:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia_drm.fbdev=1"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
