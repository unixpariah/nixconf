{
  lib,
  hyprlandPlugins,
  hyprland,
  cmake,
  fetchFromGitHub,
  nix-update-script,
}:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprscroller";
  version = "0-unstable-2025-03-24";

  src = fetchFromGitHub {
    owner = "cpiber";
    repo = "hyprscroller";
    rev = "d3e447a22cfaae77ab1cf3931d23cfdb7c010a9c";
    hash = "sha256-XqUm5nnTmZUF17eqEACzQCAWXF7ezLKHqIwJR/td34Y=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv hyprscroller.so $out/lib/libhyprscroller.so

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    homepage = "https://github.com/dawsers/hyprscroller";
    description = "Hyprland layout plugin providing a scrolling layout like PaperWM";
    license = lib.licenses.mit;
    #maintainers = builtins.attrValues { inherit (lib.maintainers) unixpariah; };
    platforms = lib.platforms.linux;
  };
}
