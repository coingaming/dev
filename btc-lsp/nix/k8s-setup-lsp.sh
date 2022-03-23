#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE=lsp

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Setting up $BITCOIN_NETWORK env for $SERVICE"

. "$THIS_DIR/../build/kubernetes/$BITCOIN_NETWORK/$SERVICE.sh"

(kubectl create secret generic "$SERVICE" \
  --from-literal=lsp_libpq_conn_str="$LSP_LIBPQ_CONN_STR" \
  --from-literal=lsp_aes256_init_vector="$LSP_AES256_INIT_VECTOR" \
  --from-literal=lsp_aes256_secret_key="$LSP_AES256_SECRET_KEY" \
  --from-literal=lsp_lnd_env="$LSP_LND_ENV" \
  --from-literal=lsp_grpc_server_env="$LSP_GRPC_SERVER_ENV" \
  --from-literal=lsp_bitcoind_env="$LSP_BITCOIND_ENV") || true

(kubectl create configmap "$SERVICE" \
  --from-literal=lsp_endpoint_port="$LSP_ENDPOINT_PORT" \
  --from-literal=lsp_log_env="$LSP_LOG_ENV" \
  --from-literal=lsp_log_format="$LSP_LOG_FORMAT" \
  --from-literal=lsp_log_verbosity="$LSP_LOG_VERBOSITY" \
  --from-literal=lsp_log_severity="$LSP_LOG_SEVERITY" \
  --from-literal=lsp_lnd_p2p_port="$LSP_LND_P2P_PORT" \
  --from-literal=lsp_lnd_p2p_host="$LSP_LND_P2P_HOST" \
  --from-literal=lsp_electrs_env="$LSP_ELECTRS_ENV") || true
