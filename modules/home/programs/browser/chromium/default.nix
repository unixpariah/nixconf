{ config, lib, ... }:
let
  cfg = config.programs.chromium;
in
{
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      #package = pkgs.ungoogled-chromium;
      extensions = [
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "gnphfcibcphlpedmaccolafjonmckcdn"; } # Extension Switch
        { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # I don't care about cookies
        { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # SponsorBlock for YouTube - Skip Sponsorships
        { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # uBlock Origin Lite
        { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
        { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # Metamask
      ];
      commandLineArgs = [
        "--disable-sync"
        "--no-default-browser-check"
        "--force-dark-mode"
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
        "--enable-features=BlockThirdPartyCookiesInIncognito"
        "--no-service-autorun"
        "--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies"
        "--disable-reading-from-canvas"
        "--no-pings"
        "--no-first-run"
        "--no-experiments"
        "--no-crash-upload"
        "--disable-wake-on-wifi"
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
        "--disable-breakpad"
        "--disable-sync"
        "--disable-speech-api"
        "--disable-speech-synthesis-api"
        "--enable-features=Vulkan"
        "--enable-features=TouchpadOverscrollHistoryNavigation,WebUIDarkMode"
        "--extension-mime-request-handling=always-prompt-for-install"
      ];
    };

    home.persist = {
      files = [
        ".config/chromium/Local State"
        ".config/chromium/Default/Cookies"
      ];
      directories = [ ".config/chromium/Default/Local Storage" ];
    };
  };
}
