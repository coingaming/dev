#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
SECRETS_DIR="$ROOT_DIR/build/secrets"

mkdir -p "$SECRETS_DIR"

genRandomString () {
  openssl rand -hex 32
}

genSecureCred () {
  SERVICE_NAME="$1"
  FILENAME="$2"
  SERVICE_PATH="$SECRETS_DIR/$SERVICE_NAME"

  mkdir -p "$SERVICE_PATH"

  echo "Saving $FILENAME in $SERVICE_PATH"
  echo -n $(genRandomString) > "$SERVICE_PATH/$FILENAME"
}

echo "==> Generating Bitcoind creds"
genSecureCred "bitcoind" "rpcuser.txt"
genSecureCred "bitcoind" "rpcpass.txt"

echo "==> Generating Lnd creds"
genSecureCred "lnd" "walletpassword.txt"

echo "==> Generating Rtl creds"
genSecureCred "rtl" "multipass.txt"

echo "==> Generating Postgres creds"
genSecureCred "postgres" "dbpassword.txt"

echo "==> Generated creds!"
