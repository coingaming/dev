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
  mkdir -p ./.grpc-tls
  cd ./.grpc-tls
  openssl genrsa -out key.pem 2048
  openssl req -new -key key.pem -out certificate.csr -subj '/CN=localhost/O=btc-lsp'
  openssl x509 -req -in certificate.csr -signkey key.pem -out certificate.pem
  rm certificate.csr
)
