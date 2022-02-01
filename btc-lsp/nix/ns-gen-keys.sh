#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"
SWARM_DIR="$BUILD_DIR/swarm"

mkdir -p "$BUILD_DIR"

echo "subjectAltName=IP:127.0.0.1,DNS:localhost" \
   > "$BUILD_DIR/subjectAltName"

(
  cd "$BUILD_DIR"
  for OWNER in lsp alice bob; do

    echo "==> Generating LND TLS cert ($OWNER)"
    SERVICE_DIR="$SHELL_DIR/lnd-$OWNER"
    TLS_KEY="$SERVICE_DIR/tls.key"
    TLS_CERT="$SERVICE_DIR/tls.cert"
    mkdir -p "$SERVICE_DIR"

    openssl ecparam -genkey -name prime256v1 -out "$TLS_KEY"
    openssl req -new -sha256 -key "$TLS_KEY" \
      -out csr.csr -subj "/CN=lnd-$OWNER/O=lnd-$OWNER"
    openssl x509 -req -in csr.csr \
      -sha256 -days 36500 \
      -extfile "$BUILD_DIR/subjectAltName" \
      -signkey "$TLS_KEY" -out "$TLS_CERT"
    rm csr.csr

  done
)

(
  echo "==> Generating deprecated ECDSA keypair"
  cd "$BUILD_DIR"
  openssl ecparam -name secp256k1 -genkey \
    -noout -outform PEM -out esdsa.prv
  openssl ec -inform PEM -in esdsa.prv \
    -pubout -outform PEM -out esdsa.pub
)

(
  echo "==> Generating LSP TLS cert"
  cd "$BUILD_DIR"
  openssl genrsa -out btc_lsp_tls_key.pem 2048
  openssl req -new -key btc_lsp_tls_key.pem \
    -out csr.csr -subj /CN=btc-lsp/O=btc-lsp
  openssl x509 -req -in csr.csr \
    -extfile "$BUILD_DIR/subjectAltName" \
    -signkey btc_lsp_tls_key.pem -out btc_lsp_tls_cert.pem
  rm csr.csr
  for RUNTIME_DIR in "$SWARM_DIR" "$SHELL_DIR"; do
    SERVICE_DIR="$RUNTIME_DIR/btc-lsp"
    mkdir -p "$SERVICE_DIR"
    cp ./btc_lsp_tls_key.pem "$SERVICE_DIR/key.pem"
    cp ./btc_lsp_tls_cert.pem "$SERVICE_DIR/cert.pem"
  done
  rm -rf ./btc_lsp_tls_key.pem
  rm -rf ./btc_lsp_tls_cert.pem
)

rm -rf "$BUILD_DIR/subjectAltName"

echo "==> Generated keys"
