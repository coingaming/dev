#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> docker swarm network setup"
sh "$THIS_DIR/ds-down.sh" || true
docker swarm leave --force || true
docker swarm init || true
docker network create -d overlay --attachable global || true

echo "==> keys generation"
echo "subjectAltName=IP:127.0.0.1,DNS:localhost" \
     > "$BUILD_DIR/subjectAltName"
sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run 'cd ./build && \
   echo DEPRECATED_ECDSA && \
   openssl ecparam -name secp256k1 -genkey \
     -noout -outform PEM -out esdsa.prv && \
   openssl ec -inform PEM -in esdsa.prv \
     -pubout -outform PEM -out esdsa.pub && \
   echo LSP_TLS && \
   openssl genrsa -out btc_lsp_tls_key.pem 2048 && \
   openssl req -new -key btc_lsp_tls_key.pem \
     -out csr.csr -subj /CN=btc-lsp/O=btc-lsp && \
   openssl x509 -req -in csr.csr \
     -extfile subjectAltName \
     -signkey btc_lsp_tls_key.pem -out btc_lsp_tls_cert.pem && \
   rm csr.csr && \
   echo LND_TLS && \
   openssl ecparam -genkey -name prime256v1 -out lnd_tls.key && \
   openssl req -new -sha256 -key lnd_tls.key \
     -out csr.csr -subj /CN=lnd/O=lnd && \
   openssl req -x509 -sha256 -days 36500 -key lnd_tls.key \
     -in csr.csr -out lnd_tls.cert && \
   rm csr.csr'
   "

echo "==> docker image build"
sh "$THIS_DIR/release-docker.sh"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

echo "==> dhall compilation"
sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run './nix/dhall-compile.sh'"

sh "$THIS_DIR/ds-up.sh"
