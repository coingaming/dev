#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"

mkdir -p "$BUILD_DIR"

newSubjectAltName () {
  SERVICE_NAME="$1"
  echo "subjectAltName=IP:127.0.0.1,DNS:localhost,DNS:127.0.0.1,DNS:$SERVICE_NAME" \
     > "$BUILD_DIR/subjectAltName"
}

deleteSubjectAltName () {
  rm -rf "$BUILD_DIR/subjectAltName"
}

(
  cd "$BUILD_DIR"
  for OWNER in lsp alice bob; do

    echo "==> Generating LND TLS cert ($OWNER)"
    SERVICE_NAME="lnd-$OWNER"
    SERVICE_DIR="$SHELL_DIR/$SERVICE_NAME"
    TLS_KEY="$SERVICE_DIR/tls.key"
    TLS_CERT="$SERVICE_DIR/tls.cert"
    mkdir -p "$SERVICE_DIR"

    newSubjectAltName "$SERVICE_NAME"
    openssl ecparam -genkey -name prime256v1 -out "$TLS_KEY"
    openssl req -new -sha256 -key "$TLS_KEY" \
      -out csr.csr -subj "/CN=$SERVICE_NAME/O=$SERVICE_NAME"
    openssl x509 -req -in csr.csr \
      -sha256 -days 36500 \
      -extfile "$BUILD_DIR/subjectAltName" \
      -signkey "$TLS_KEY" -out "$TLS_CERT"
    rm csr.csr
    deleteSubjectAltName

  done
)

(
  echo "==> Generating LSP TLS cert"
  cd "$BUILD_DIR"
  SERVICE_NAME="btc-lsp"

  newSubjectAltName "$SERVICE_NAME"
  openssl genrsa -out btc_lsp_tls_key.pem 2048
  openssl req -new -key btc_lsp_tls_key.pem \
    -out csr.csr -subj "/CN=$SERVICE_NAME/O=$SERVICE_NAME"
  openssl x509 -req -in csr.csr \
    -extfile "$BUILD_DIR/subjectAltName" \
    -signkey btc_lsp_tls_key.pem -out btc_lsp_tls_cert.pem
  rm csr.csr
  deleteSubjectAltName

  for RUNTIME_DIR in "$SHELL_DIR"; do
    SERVICE_DIR="$RUNTIME_DIR/$SERVICE_NAME"
    mkdir -p "$SERVICE_DIR"
    cp ./btc_lsp_tls_key.pem "$SERVICE_DIR/key.pem"
    cp ./btc_lsp_tls_cert.pem "$SERVICE_DIR/cert.pem"
  done
  rm -rf ./btc_lsp_tls_key.pem
  rm -rf ./btc_lsp_tls_cert.pem
)

echo "==> Generated keys"
