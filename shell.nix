{ pkgs }:
with pkgs;
mkShell {
  buildInputs = [
    helm-ls
    helmfile
    terraform-ls
    jq
    nixd
    nixfmt-rfc-style
    kustomize
    (terraform.withPlugins (p: [
      p.null
      p.external
    ]))
    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
    helm-ls
    yaml-language-server
    prettier
  ];
}
