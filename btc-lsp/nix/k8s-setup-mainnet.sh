#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"

BITCOIN_NETWORK="mainnet"

confirmAction \
"==> Clean up previous build?" \
"cleanBuildDir"

askForDomainName
checkRequiredFiles

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

confirmContinue "==> Deploy to $BITCOIN_NETWORK?"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "bitcoind lnd"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "bitcoind lnd"

echo "==> Initializing LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"
sleep 20

echo "==> Exporting creds from running pods"
sh "$THIS_DIR/k8s-export-creds.sh"

echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
