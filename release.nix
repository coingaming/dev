let
  p = (import ./nix/project.nix).project {};

in {
  generic-pretty-instances = p.generic-pretty-instances.components.tests.generic-pretty-instances-test;
  btcLspTest = p.btc-lsp.components.tests.btc-lsp-test;
}
