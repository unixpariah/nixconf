{
  description = "My nixconfig";

  outputs =
    {
      nixpkgs,
      disko,
      home-manager,
      stylix,
      nix-on-droid,
      system-manager,
      nix-raspberrypi,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      hostEval = nixpkgs.lib.evalModules {
        modules = [
          { _module.args.inputs = inputs; }
          ./configuration.nix
          ./utils/options.nix
        ];
      };

      inherit (hostEval) config;

      mkHome =
        hostName: username:
        let
          pkgs = import nixpkgs {
            inherit (config.hosts.${hostName}) system;
          };
          shell = "${config.hosts.${hostName}.users.${username}.shell}";
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs shell;
            inherit (config.hosts.${hostName}) platform profile;
          };

          modules = [
            ./modules/home
            ./modules/common/home
            ./hosts/${hostName}/users/${username}
            stylix.homeModules.stylix
            {
              networking = { inherit hostName; };
              home = {
                inherit username;
                homeDirectory = config.hosts.${hostName}.users.${username}.home;
              };
            }
          ];
        };

      forAllSystems =
        function:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          function pkgs
        );
      inherit (nixpkgs) lib;
    in
    {
      devShells =
        let
          forAllSystems =
            function:
            nixpkgs.lib.genAttrs systems (
              system:
              let
                pkgs = import nixpkgs {
                  inherit system;
                  config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "terraform" ];
                };
              in
              function pkgs
            );

        in
        forAllSystems (pkgs: {
          default = pkgs.mkShell {
            buildInputs =
              builtins.attrValues {
                inherit (pkgs)
                  lix
                  git
                  nixd
                  terraform-ls
                  nixfmt
                  jq
                  ;
              }
              ++ [ (pkgs.terraform.withPlugins (p: builtins.attrValues { inherit (p) null external; })) ];
          };
        });

      nixosConfigurations =
        let
          mkHost =
            hostName: attrs:
            let
              nixosSystem =
                if attrs.platform == "rpi-nixos" then nix-raspberrypi.lib.nixosSystem else nixpkgs.lib.nixosSystem;
            in
            nixosSystem {
              specialArgs = {
                inherit inputs;
                systemUsers = attrs.users;
                inherit (config.hosts.${hostName}) system profile platform;
              };
              modules = [
                ./modules/nixos
                ./modules/common/nixos
                ./hosts/${hostName}
                disko.nixosModules.default
                stylix.nixosModules.stylix
                { networking = { inherit hostName; }; }
              ]
              ++ lib.optionals (attrs.platform == "rpi-nixos") (
                builtins.attrValues {
                  inherit (nixpkgs.nixos-raspberrypi.nixosModules.raspberry-pi-5) base display-vc4 bluetooth;
                }
              );
            };
        in
        config.hosts
        |> lib.filterAttrs (_: attrs: attrs.platform == "nixos")
        |> lib.mapAttrs (hostName: attrs: mkHost hostName attrs);

      systemConfigs =
        let
          mkHost =
            hostName: attrs:
            let
              systemUsers = attrs.users;
              pkgs = import nixpkgs { inherit (attrs) system; };
            in
            system-manager.lib.makeSystemConfig {
              modules = [
                ./modules/system
                ./hosts/${hostName}
              ];
              extraSpecialArgs = {
                inherit inputs systemUsers pkgs;
                inherit (config.hosts.${hostName}) system profile;
              };
            };
        in
        config.hosts
        |> lib.filterAttrs (_: attrs: attrs.platform == "non-nixos")
        |> lib.mapAttrs (hostName: attrs: mkHost hostName attrs);

      homeConfigurations =
        config.hosts
        |> lib.filterAttrs (_: attrs: attrs.platform != "mobile")
        |> builtins.attrNames
        |> builtins.map (
          host:
          config.hosts.${host}.users
          |> builtins.attrNames
          |> builtins.map (user: {
            name = "${user}@${host}";
            value = mkHome host user;
          })
        )
        |> builtins.concatLists
        |> builtins.listToAttrs;

      nixOnDroidConfigurations =
        let
          mkDroid =
            hostName: attrs:
            nix-on-droid.lib.nixOnDroidConfiguration {
              pkgs = import nixpkgs { inherit (config.hosts.${hostName}) system; };
              modules = [
                ./hosts/${hostName}
                ./modules/nixOnDroid
              ];
            };
        in
        config.hosts
        |> lib.filterAttrs (_: attrs: attrs.platform == "mobile")
        |> lib.mapAttrs (hostName: attrs: mkDroid hostName attrs);

      formatter = forAllSystems (
        pkgs:
        pkgs.writeShellApplication {
          name = "nix3-fmt-wrapper";

          runtimeInputs = [
            pkgs.nixfmt-rfc-style
            pkgs.fd
          ];

          text = ''
            fd "$@" -t f -e nix -x nixfmt -q '{}'
          '';
        }
      );
    };

  inputs = {
    # Necessary
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mox-flake.url = "github:mox-desktop/mox-flake";

    # To be ditched

    # Just copy paste addons from nur-expressions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake"; # wait for kdl parser to be implemented in nixpkgs
    # No idea, I dont really use it anymore anyways so maybe just remove
    nixvim = {
      url = "github:unixpariah/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # No clue, I like to have it for my non NixOS machines but at the same time it feels weird
    # to have it in my inputs
    nh-system = {
      url = "github:unixpariah/nh/system-manager-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Maybe just maintain a derivation? Not gonna change it a lot anyways
    sysnotifier = {
      url = "github:unixpariah/SysNotifier";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
