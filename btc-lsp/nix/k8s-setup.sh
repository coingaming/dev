#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SETUP_MODE="--prebuilt"
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"

if [ -z "$*" ]; then
  echo "==> using defaults"
else
  for arg in "$@"; do
    case $arg in
      --source)
        SETUP_MODE="$arg"
        shift
        ;;
      --prebuilt)
        SETUP_MODE="$arg"
        shift
        ;;
      *)
        echo "==> unrecognized arg $arg"
        exit 1
        ;;
    esac
  done
fi

echo "==> Setup kubernetes cluster"
sh "$THIS_DIR/k8s-setup-cluster.sh"

echo "==> Build cleanup"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Generate keys"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/k8s-gen-keys.sh && ./nix/ns-inline-creds.sh'"

case $SETUP_MODE in
  --source)
    echo "==> Building from source"
    sh "$THIS_DIR/hm-release.sh"
    ;;
  --prebuilt)
    (
      echo "==> Using prebuilt"
      cd "$BUILD_DIR"
      rm -rf docker-image-*
      wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-btc-lsp.tar.gz"
      wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-integration.tar.gz"
    )
    ;;
  *)
    echo "==> Unrecognized SETUP_MODE $SETUP_MODE"
    exit 1
    ;;
esac

echo "==> Loading btc-lsp docker image"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Loading btc-lsp docker image into minikube"
minikube image load \
  -p "$MINIKUBE_PROFILE" \
  --daemon=true $(cat "$BUILD_DIR/docker-image-btc-lsp.txt")

echo "==> Loading integration docker image"
docker load -q -i "$BUILD_DIR/docker-image-integration.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-integration.txt"

echo "==> Loading integration docker image into minikube"
minikube image load \
  -p "$MINIKUBE_PROFILE" \
  --daemon=true $(cat "$BUILD_DIR/docker-image-integration.txt")

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/k8s-dhall-compile.sh'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh"

echo "==> Partial spin"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"
sleep 20

echo "==> Generate additional creds"
sh "$THIS_DIR/k8s-gen-creds.sh"

echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-inline-creds.sh && ./nix/k8s-dhall-compile.sh'"

echo "==> Updating environment for containers"
kubectl delete secret rtl lsp
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Restarting k8s deployments"
sh "$THIS_DIR/k8s-restart.sh" rtl
sh "$THIS_DIR/k8s-restart.sh" lsp

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh"

echo "==> Mine initial coins"
sh "$THIS_DIR/k8s-mine.sh" 105
