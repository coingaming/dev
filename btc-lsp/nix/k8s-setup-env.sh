#!/bin/bash

set -e

inline() {
  awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $1
}

THIS_DIR="$(dirname "$(realpath "$0")")"
DEFAULT_PASSWORD=developer
BITCOIN_RPCUSER=bitcoinrpc
BITCOIN_NETWORK=regtest
LND_TLS_CERT=$(inline <$THIS_DIR/../build/swarm/lnd-lsp/tls.cert) || printf "TODO"
LND_HEX_MACAROON=$(<$THIS_DIR/../build/swarm/lnd-lsp/macaroon-$BITCOIN_NETWORK.hex) || printf "TODO"
BTC_LSP_TLS_CERT=$(inline <$THIS_DIR/../build/swarm/btc-lsp/cert.pem)
BTC_LSP_TLS_KEY=$(inline <$THIS_DIR/../build/swarm/btc-lsp/key.pem)

echo "==> Setting up ENV for bitcoind"
(kubectl create secret generic bitcoind \
  --from-literal=rpcuser=$BITCOIN_RPCUSER \
  --from-literal=rpcpassword=$DEFAULT_PASSWORD) || true

(kubectl create configmap bitcoind \
  --from-literal=config_from_env=true \
  --from-literal=disablewallet=0 \
  --from-literal=prune=0 \
  --from-literal=regtest=1 \
  --from-literal=rpcallowip="0.0.0.0/0" \
  --from-literal=rpcbind=":18332" \
  --from-literal=rpcport=18332 \
  --from-literal=server=1 \
  --from-literal=testnet=0 \
  --from-literal=txindex=1 \
  --from-literal=zmqpubrawblock="tcp://0.0.0.0:39703" \
  --from-literal=zmqpubrawtx="tcp://0.0.0.0:39704") || true

echo "==> Setting up ENV for lnd-lsp"
(kubectl create secret generic lnd-lsp \
  --from-literal=bitcoin_rpcuser=$BITCOIN_RPCUSER \
  --from-literal=bitcoin_rpcpass=$DEFAULT_PASSWORD) || true

(kubectl create configmap lnd-lsp \
  --from-literal=bitcoin_defaultchanconfs=1 \
  --from-literal=bitcoin_network=$BITCOIN_NETWORK \
  --from-literal=bitcoin_rpchost=bitcoind:18332 \
  --from-literal=bitcoin_zmqpubrawblock=tcp://bitcoind:39703 \
  --from-literal=bitcoin_zmqpubrawtx=tcp://bitcoind:39704 \
  --from-literal=lnd_grpc_port=10009 \
  --from-literal=lnd_p2p_port=9735 \
  --from-literal=lnd_rest_port=8080 \
  --from-literal=tls_extradomain=lnd-lsp) || true

echo "==> Setting up ENV for rtl"
(kubectl create secret generic rtl \
  --from-literal=rtl_config_nodes_json='[
    {
      "hexMacaroon": "'$LND_HEX_MACAROON'",
      "index": 1,
      "lnServerUrl": "https://lnd-lsp:8080"
    }
  ]' \
  --from-literal=rtl_config_json='{
    "SSO":{
      "logoutRedirectLink": "",
      "rtlCookiePath": "",
      "rtlSSO": 0
    },
    "defaultNodeIndex": 1,
    "multiPass": "'$DEFAULT_PASSWORD'",
    "nodes": [],
    "port": "80"
  }') || true

(kubectl create configmap rtl \
  --from-literal=config_from_env=true) || true

echo "==> Setting up ENV for btc-lsp"
(kubectl create secret generic btc-lsp \
  --from-literal=lsp_libpq_conn_str="postgresql://btc-lsp:$DEFAULT_PASSWORD@postgres/btc-lsp" \
  --from-literal=lsp_aes256_init_vector="dRgUkXp2s5v8y/B?" \
  --from-literal=lsp_aes256_secret_key="y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN" \
  --from-literal=lsp_lnd_env='{
    "lnd_wallet_password":"'$DEFAULT_PASSWORD'",
    "lnd_tls_cert":"'"$LND_TLS_CERT"'",
    "lnd_hex_macaroon":"'$LND_HEX_MACAROON'",
    "lnd_host":"lnd-lsp",
    "lnd_port":10009
  }' \
  --from-literal=lsp_grpc_server_env='{
    "port":8443,
    "sig_verify":true,
    "sig_header_name":"sig-bin",
    "tls_cert":"'"$BTC_LSP_TLS_CERT"'",
    "tls_key":"'"$BTC_LSP_TLS_KEY"'"
  }' \
  --from-literal=lsp_bitcoind_env='{
    "host":"http://bitcoind:18332",
    "username":"'$BITCOIN_RPCUSER'",
    "password":"'$DEFAULT_PASSWORD'"
  }') || true

(kubectl create configmap btc-lsp \
  --from-literal=lsp_endpoint_port=8443 \
  --from-literal=lsp_log_env=test \
  --from-literal=lsp_log_format=Bracket \
  --from-literal=lsp_log_verbosity=V3 \
  --from-literal=lsp_log_severity=DebugS \
  --from-literal=lsp_electrs_env='{
    "host":"electrs",
    "port":"80"
  }') || true

echo "==> Setting up ENV for postgres"
(kubectl create secret generic postgres \
  --from-literal=postgres_user=btc-lsp \
  --from-literal=postgres_password=$DEFAULT_PASSWORD) || true

(kubectl create configmap postgres \
  --from-literal=postgres_multiple_databases=btc-lsp) || true
