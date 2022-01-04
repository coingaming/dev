#!/bin/sh

(
  cd ./.lnd
  openssl ecparam -genkey -name prime256v1 -out tls.key
  openssl req -new -sha256 -key tls.key -out csr.csr -subj '/CN=localhost/O=lnd'
  openssl req -x509 -sha256 -days 36500 -key tls.key -in csr.csr -out tls.cert
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

