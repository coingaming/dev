let
  header = (import ./header.nix);
  pkgs = header.nixPkgs;
  electrs = pkgs.electrs;
  entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
    echo "auth='$BITCOIND_USER:$BITCOIND_PASSWORD'" \
      >> /.electrs/electrs.toml && \
    echo "log_filters = 'INFO'" \
      >> /.electrs/electrs.toml && \
    ${electrs}/bin/electrs \
      --conf="/.electrs/electrs.toml" \
      --db-dir="/.electrs/db" \
      --network="$NETWORK" \
      --electrum-rpc-addr="$ELECTRUM_RPC_ADDR" \
      --daemon-rpc-addr="$DAEMON_RPC_ADDR" \
      --wait-duration-secs="$WAIT_DURATION_SECS" \
      --jsonrpc-import \
      --timestamp
  '';
in
  pkgs.dockerTools.buildImage {
    name = "heathmont/electrs";
    contents = [ entrypoint ];
    config = {
      Cmd = [ "${entrypoint}/bin/entrypoint" ];
      ExposedPorts = { "80/tcp" = {}; };
    };
  }
