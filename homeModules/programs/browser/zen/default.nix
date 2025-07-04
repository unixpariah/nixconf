{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.zen;
in
{
  options.programs.zen.enable = lib.mkEnableOption "zen";

  imports = [ inputs.zen-browser.homeModules.default ];

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
      };

      profiles."${config.home.username}" = {
        search = {
          force = true;
          default = "brave";
          order = [
            "brave"
            "searx"
          ];

          engines = {
            "brave" = {
              urls = [ { template = "https://search.brave.com/search?q={searchTerms}"; } ];
              definedAliases = [ "b" ];
            };

            "searx" = {
              urls = [
                {
                  template = "https://opnxng.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "categories";
                      value = "general";
                    }
                    {
                      name = "language";
                      value = "all";
                    }
                    {
                      name = "safesearch";
                      value = "0";
                    }
                  ];
                }
              ];
              definedAliases = [ "s" ];
            };
          };
        };

        bookmarks = {
          force = true;
          settings = [
            {
              name = "my apps";
              toolbar = true;
              bookmarks = [
                {
                  name = "moxwiki";
                  keyword = "ah";
                  url = "https://moxwiki.your-domain.com";
                }
              ];
            }
          ];
        };

        extensions = {
          force = true;
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            keepassxc-browser
            ublock-origin
            sponsorblock
            darkreader
            vimium
            youtube-shorts-block
            bitwarden
          ];
          settings = {
            "uBlock0@raymondhill.net".settings = {
              # Get your settings here
              # ~/.zen/YOUR_PROFILE_NAME/browser-extension-data/uBlock0@raymondhill.net/storage.js
              advancedUserEnabled = true;
              selectedFilterLists = [
                "user-filters"
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-unbreak"
                "ublock-quick-fixes"
                "easylist"
                "easyprivacy"
                "urlhaus-1"
                "plowe-0"
                "adguard-spyware-url"
                "fanboy-cookiemonster"
                "ublock-cookies-easylist"
                "easylist-annoyances"
                "easylist-chat"
                "easylist-newsletters"
                "easylist-notifications"
                "ublock-annoyances"
                "IDN-0"
              ];
              "user-filters" = ''
                shopee.co.id##li.col-xs-2-4.shopee-search-item-result__item:has(div:contains(Ad))
                shopee.co.id##.oMSmr0:has(div:contains(Ad))
                tokopedia.com#?#.product-card:has(span:-abp-contains(/^Ad$/))
                tokopedia.com##a[data-testid="lnkProductContainer"]:has(img[alt^="topads"])
                tokopedia.com##div[data-ssr="findProductSSR"]:has(span[data-testid="lblTopads"])
                tokopedia.com##div[data-ssr="findProductSSR"]:has(span[data-testid="linkProductTopads"])
                tokopedia.com##div[data-testid="CPMWrapper"]
                tokopedia.com#?#div[data-testid="divCarouselProduct"]:has(span:-abp-contains(/^Ad$/))
                tokopedia.com##div[data-testid="divProduct"]:has(span[data-testid="icnHomeTopadsRecom"])
                tokopedia.com##div[data-testid="divProductWrapper"]:has(span[data-testid="divSRPTopadsIcon"])
                tokopedia.com##div[data-testid="featuredShopCntr"]
                tokopedia.com#?#div[data-testid="lazy-frame"]:has(span:-abp-contains(/^Ad$/))
                tokopedia.com##div[data-testid="lazy-frame"]:has(span[data-testid="lblProdTopads"])
                tokopedia.com##div[data-testid="master-product-card"]:has(span[data-testid^="linkProductTopads"])
                tokopedia.com##div[data-testid="topadsCPMWrapper"]
                tokopedia.com#?#div[data-testid^="divProductRecommendation"]:has(span:-abp-contains(/^Ad$/))
                tokopedia.com##div[data-testid^="divProductRecommendation"]:has(span[data-testid="icnHomeTopadsRecom"])
              '';
            };
          };
        };
      };
    };

    home = {
      persist.directories = [
        ".cache/zen"
        ".zen"
      ];
    };
  };
}
