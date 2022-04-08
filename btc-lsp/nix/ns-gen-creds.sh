#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
SECRETS_DIR="$ROOT_DIR/build/secrets"

mkdir -p "$SECRETS_DIR"

newSubjectAltName () {
  BUILD_PATH="$1"
  SERVICE_NAME="$2"
  echo "subjectAltName=IP:127.0.0.1,DNS:localhost,DNS:127.0.0.1,DNS:$SERVICE_NAME,DNS:$SERVICE_NAME" \
     > "$BUILD_PATH/subjectAltName"
}

deleteSubjectAltName () {
  BUILD_PATH="$1"
  rm -rf "$BUILD_PATH/subjectAltName"
}

genCert () {
  SERVICE_NAME="$1"
  BUILD_PATH="$SECRETS_DIR/$SERVICE_NAME"

  mkdir -p "$BUILD_PATH"

  TLS_KEY_PATH="$BUILD_PATH/tls.key"
  TLS_CERT_PATH="$BUILD_PATH/tls.cert"
  CSR_PATH="$BUILD_PATH/csr.csr"

  newSubjectAltName "$BUILD_PATH" "$SERVICE_NAME" 
  openssl genrsa -out "$TLS_KEY_PATH" 2048
  openssl req -new -key "$TLS_KEY_PATH" \
    -out "$CSR_PATH" -subj "/CN=$SERVICE_NAME/O=$SERVICE_NAME"
  openssl x509 -req -in "$CSR_PATH" \
    -extfile "$BUILD_PATH/subjectAltName" \
    -signkey "$TLS_KEY_PATH" -out "$TLS_CERT_PATH"
  rm "$CSR_PATH"
  deleteSubjectAltName "$BUILD_PATH"
}

genRandomString () {
  openssl rand -base64 32
}

genSecureCred () {
  SERVICE_NAME="$1"
  FILENAME="$2"
  BUILD_PATH="$SECRETS_DIR/$SERVICE_NAME"

  mkdir -p "$BUILD_PATH"

  echo "Saving $FILENAME in $BUILD_PATH"
  echo -n `genRandomString` > "$BUILD_PATH/$FILENAME"
}

echo "==> Generating Bitcoind creds"
genSecureCred "bitcoind" "rpcuser.txt"
genSecureCred "bitcoind" "rpcpass.txt"

echo "==> Generating Lnd creds"
genSecureCred "lnd" "walletpassword.txt"

echo "==> Generating Rtl creds"
genSecureCred "rtl" "multipass.txt"
genCert "rtl"

echo "==> Generating Lsp creds"
genCert "lsp"

echo "==> Generated creds!"
