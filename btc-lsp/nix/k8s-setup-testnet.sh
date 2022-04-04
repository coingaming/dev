#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-setup-utilities.sh"

BITCOIN_NETWORK="testnet"

createKubernetesCluster () {
  local K8S_CLUSTER_NAME="$1"

  echo "Creating \"$K8S_CLUSTER_NAME\" k8s cluster on DigitalOcean..."
  doctl kubernetes cluster create "$K8S_CLUSTER_NAME" \
    --count 3 \
    --region ams3 \
    --1-clicks ingress-nginx \
    --size s-4vcpu-8gb
}

deleteKubernetesCluster () {
  local K8S_CLUSTER_NAME="$1"

  echo "Deleting \"$K8S_CLUSTER_NAME\" k8s cluster from DigitalOcean..."
  doctl kubernetes cluster delete "$K8S_CLUSTER_NAME" --dangerous
}

setupKubernetesCluster () {
  isInstalled doctl && doctl account get

  local K8S_CLUSTER_NAME="$1"

  if doctl kubernetes cluster get "$K8S_CLUSTER_NAME"; then
    confirmAction \
    "==> Delete existing \"$K8S_CLUSTER_NAME\" k8s cluster and create a new one?" \
    "deleteKubernetesCluster $K8S_CLUSTER_NAME && createKubernetesCluster $K8S_CLUSTER_NAME"
  else
    confirmAction \
    "==> Create new \"$K8S_CLUSTER_NAME\" k8s cluster?" \
    "createKubernetesCluster $K8S_CLUSTER_NAME"
  fi
}

getPostgresInstanceId () {
  local PG_INSTANCE_NAME="$1"

  doctl databases list --no-header | grep "$PG_INSTANCE_NAME" | awk '{print $1}'
}

createPostgresInstance () {
  local PG_INSTANCE_NAME="$1"

  echo "Creating \"$PG_INSTANCE_NAME\" database instance on DigitalOcean..."
  doctl databases create "$PG_INSTANCE_NAME" \
    --engine pg \
    --region ams3 \
    --size db-s-1vcpu-1gb
}

deletePostgresInstance () {
  local PG_INSTANCE_NAME="$1"

  echo "Deleting \"$PG_INSTANCE_NAME\" database instance from DigitalOcean..."
  doctl databases delete `getPostgresInstanceId $PG_INSTANCE_NAME`
}

writePostgresURI () {
  local PG_INSTANCE_NAME="$1"
  local PG_INSTANCE_ID=`getPostgresInstanceId $1`
  local PG_URI=`doctl databases connection $PG_INSTANCE_ID --format URI --no-header`
  local PG_CONN_PATH="$POSTGRES_PATH/conn.txt"

  echo "==> Saving pg connection details"
  mkdir -p "$POSTGRES_PATH"

  echo -n "$PG_URI" > "$PG_CONN_PATH"
  echo "Saved connection details to $PG_CONN_PATH"
}

setupPostgresInstance () {
  isInstalled doctl && doctl account get

  local PG_INSTANCE_NAME="$1"
  local PG_INSTANCE_ID=`getPostgresInstanceId $PG_INSTANCE_NAME`

  if [ -n "$PG_INSTANCE_ID" ]; then
    confirmAction \
    "==> Delete existing \"$PG_INSTANCE_NAME\" database instance and create a new one?" \
    "deletePostgresInstance $PG_INSTANCE_NAME && createPostgresInstance $PG_INSTANCE_NAME && writePostgresURI $PG_INSTANCE_NAME"
  else
    confirmAction \
    "==> Create new \"$PG_INSTANCE_NAME\" database instance?" \
    "createPostgresInstance $PG_INSTANCE_NAME && writePostgresURI $PG_INSTANCE_NAME"
  fi
}

confirmAction \
"==> Clean up previous build?" \
"cleanBuildDir"

askForDomainName

confirmAction \
"==> Setup LetsEncrypt certificate?" \
"setupLetsEncryptCert"

checkRequiredFiles

setupKubernetesCluster "lsp-$BITCOIN_NETWORK"
setupPostgresInstance "lsp-$BITCOIN_NETWORK"

echo "==> Checking that postgres connection details are saved"
checkFileExistsNotEmpty "$POSTGRES_PATH/conn.txt" 
echo "Connection details are OK."

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-inline-creds.sh && ./nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

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
   "--run './nix/ns-inline-creds.sh && ./nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
