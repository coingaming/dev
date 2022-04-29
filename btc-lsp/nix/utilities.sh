#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SECRETS_DIR="$BUILD_DIR/secrets"

export BITCOIND_PATH="$SECRETS_DIR/bitcoind"
export LND_PATH="$SECRETS_DIR/lnd"
export RTL_PATH="$SECRETS_DIR/rtl"
export LSP_PATH="$SECRETS_DIR/lsp"
export POSTGRES_PATH="$SECRETS_DIR/postgres"

confirmAction () {
  local ASK="$1"
  local ACTION="$2"
  local CONFIRM

  while true; do
    read -r -p "$ASK (y/N) ? " CONFIRM
    case "$CONFIRM" in
      [Yy]* ) eval "$ACTION"; break;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

confirmContinue () {
  local ASK="$1"
  local CONFIRM

  while true; do
    read -r -p "$ASK (y/N) ? " CONFIRM
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

writeServiceDomainNames () {
  for SERVICE_NAME in bitcoind lnd rtl lsp; do
    local SERVICE_DIR="$SECRETS_DIR/$SERVICE_NAME"
    local SERVICE_DOMAIN_NAME="$SERVICE_NAME.$DOMAIN_NAME"
    local SERVICE_DOMAIN_NAME_FILEPATH="$SERVICE_DIR/domainname.txt"

    echo "Saving $SERVICE_DOMAIN_NAME to $SERVICE_DOMAIN_NAME_FILEPATH"
    echo -n "$SERVICE_DOMAIN_NAME" > "$SERVICE_DOMAIN_NAME_FILEPATH"
  done
}

writeDomainName () {
  local DOMAIN_NAME_FILEPATH="$1"

  echo "==> Domain name must be set before continuing"
  read -r -p "Input your domain name: " "DOMAIN_NAME"

  echo "Saving $DOMAIN_NAME to $DOMAIN_NAME_FILEPATH"
  echo -n "$DOMAIN_NAME" > "$DOMAIN_NAME_FILEPATH"
}

setDomainName () {
  local DOMAIN_NAME_FILEPATH="$BUILD_DIR/domainname.txt"

  if [ -s "$DOMAIN_NAME_FILEPATH" ]; then
    DOMAIN_NAME=$(cat "$DOMAIN_NAME_FILEPATH")
  else
    writeDomainName "$DOMAIN_NAME_FILEPATH"
    writeServiceDomainNames
  fi
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
