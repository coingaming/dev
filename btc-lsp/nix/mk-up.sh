#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/mk-setup-profile.sh"

minikube start

sh "$THIS_DIR/mk-setup-kubeconf.sh"

echo "==> Unlocking LND wallets"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh bitcoind lnd lnd-alice lnd-bob rtl lsp"
