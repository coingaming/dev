#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SECRETS_DIR="$BUILD_DIR/secrets"

BITCOIND_PATH="$SECRETS_DIR/bitcoind"
LND_PATH="$SECRETS_DIR/lnd"
RTL_PATH="$SECRETS_DIR/rtl"
LSP_PATH="$SECRETS_DIR/lsp"
POSTGRES_PATH="$SECRETS_DIR/postgres"
DATABASE_URI_PATH="$POSTGRES_PATH/dburi.txt"

confirmAction () {
  local ASK="$1"
  local ACTION="$2"

  while true; do
    read -p "$ASK (y/N) ? " CONFIRM
    case "$CONFIRM" in
      [Yy]* ) eval "$ACTION"; break;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

confirmContinue () {
  local ASK="$1"

  while true; do
    read -p "$ASK (y/N) ? " CONFIRM
    case "$CONFIRM" in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

cleanBuildDir () {
  echo "Deleting everything in $BUILD_DIR"
  rm -rfv "$BUILD_DIR" && mkdir -p "$BUILD_DIR"
}

isInstalled () {
  local COMMAND_NAME="$1"

  if ! command -v "$COMMAND_NAME" &> /dev/null; then
    echo "Please install \"$COMMAND_NAME\" before continuing"
    exit 1;
  fi
}

setDomainName () {
  echo "==> Domain name must be set before continuing"
  read -p "Input your domain name: " "DOMAIN_NAME"
}

writeDomainName () {
  for SERVICE in bitcoind lnd rtl lsp; do
    local SERVICE_DIR="$SECRETS_DIR/$SERVICE"
    local SERVICE_DOMAIN="$SERVICE.$DOMAIN_NAME"
    local SERVICE_DOMAIN_FILEPATH="$SERVICE_DIR/domainname.txt"

    if [ ! -f "$SERVICE_DOMAIN_FILEPATH" ]; then
      mkdir -p "$SERVICE_DIR"

      echo "Saving $SERVICE_DOMAIN to $SERVICE_DOMAIN_FILEPATH"
      echo -n "$SERVICE_DOMAIN" > "$SERVICE_DOMAIN_FILEPATH"
    fi
  done
}

checkFileExistsNotEmpty () {
  local FILEPATH="$1"

  if [ -f "$FILEPATH" ]; then
    if [ ! -s "$FILEPATH" ]; then
      echo "$FILEPATH is empty"
      exit 1;
    fi
  else
    echo "$FILEPATH does not exist"
    exit 1;
  fi
}

checkRequiredFiles () {
  echo "==> Checking that all required files exist and are not empty"
  checkFileExistsNotEmpty "$BITCOIND_PATH/rpcuser.txt" 
  checkFileExistsNotEmpty "$BITCOIND_PATH/rpcpass.txt"
  checkFileExistsNotEmpty "$LND_PATH/walletpassword.txt" 
  checkFileExistsNotEmpty "$RTL_PATH/multipass.txt"
  checkFileExistsNotEmpty "$POSTGRES_PATH/dbpassword.txt"
  echo "All files are OK."
}

genSecureCreds () {
  echo "==> Generating new credentials"
  sh "$THIS_DIR/hm-shell-docker.sh" \
    --mini \
    "--run './nix/ns-gen-creds.sh'"
}
