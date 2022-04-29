let
  header = (import ./header.nix);
  nixPkgs = header.nixPkgs;
  lnd = import ./lnd-conf.nix;
  bitcoind = import ./bitcoin-conf.nix;
in let
  dataDir = "./tmp";
  macaroonDir = "../btc-lsp/test/Macaroon/";
  bitcoinNodeFn = bitcoind { inherit dataDir; name="regtest"; };
  lndNodeFns = map lnd [{
    inherit dataDir macaroonDir;
    port = 9735;
    rpcport = 10009;
    restport = 8080;
    name = "lsp";
  }
  {
    inherit dataDir macaroonDir;
    port = 9736;
    rpcport = 10010;
    restport = 8081;
    name = "alice";
  }
  {
    inherit dataDir macaroonDir;
    port = 9737;
    rpcport = 10011;
    restport = 8082;
    name = "bob";
  }
];
  l = nixPkgs.lib;
  concatStrLn = builtins.concatStringsSep "\n";
  runBinStr = t : d : "${d}/bin/${t}";
  runBins = name : lst : l.pipe lst [
    (map (runBinStr name))
    concatStrLn
  ];
  cl = p : nixPkgs.callPackage p {};
  bitcoinNode = nixPkgs.callPackage bitcoinNodeFn {};
  lndNodes = map cl lndNodeFns;
  nodesInOrder = [bitcoinNode] ++ lndNodes;

  startEverything = nixPkgs.writeShellScriptBin "start" ''
    ${runBins "start" nodesInOrder}
  '';
  stopEverything = nixPkgs.writeShellScriptBin "stop" ''
    ${runBins "stop" (l.reverseList nodesInOrder)}
  '';
  setupEverything = nixPkgs.writeShellScriptBin "setup" ''
    ${runBins "setup" nodesInOrder}
  '';
in
nixPkgs.symlinkJoin {
  name = "test-cluster";
  paths = [ startEverything stopEverything setupEverything];
  postBuild = ''
    echo "Symlinks scripts created in $out/bin"
  '';
}

