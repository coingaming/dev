#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
LND_DIR="$ROOT_DIR/.lnd"

mkdir -p "$BUILD_DIR"

echo "subjectAltName=IP:127.0.0.1,DNS:localhost" \
   > "$BUILD_DIR/subjectAltName"

(
  #
  # TODO : generate individually for every lnd instance
  #
  echo "==> Generating LND TLS cert"
  cd "$LND_DIR"
  openssl ecparam -genkey -name prime256v1 -out tls.key
  openssl req -new -sha256 -key tls.key \
    -out csr.csr -subj /CN=lnd/O=lnd
  openssl x509 -req -in csr.csr \
    -sha256 -days 36500 \
    -extfile "$BUILD_DIR/subjectAltName" \
    -signkey tls.key -out tls.cert
  rm csr.csr
  cp "$LND_DIR/tls.key" "$BUILD_DIR/lnd_tls.key"
  cp "$LND_DIR/tls.cert" "$BUILD_DIR/lnd_tls.cert"
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
)

echo "==> Generated certs"
