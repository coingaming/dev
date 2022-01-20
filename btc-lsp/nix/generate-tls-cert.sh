#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

mkdir -p "$BUILD_DIR"

echo "subjectAltName=IP:127.0.0.1,DNS:localhost" \
   > "$BUILD_DIR/subjectAltName"

(
  #
  # TODO : generate individually for every lnd instance
  #
  cd ./.lnd
  openssl ecparam -genkey -name prime256v1 -out tls.key
  openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=lnd'
  openssl x509 -req -in csr.csr \
    -sha256 -days 36500 \
    -extfile "$BUILD_DIR/subjectAltName" \
    -signkey tls.key -out tls.cert
  rm csr.csr
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

echo "==> Generated TLS certs"
