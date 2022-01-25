#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SWARM_DIR="$THIS_DIR/../build/swarm"

for NET in regtest testnet mainnet; do
  for OWNER in lsp; do
    SERVICE="yolo_lnd-$OWNER"
    CONTAINER=`docker ps -f name="$SERVICE" --quiet`
    SERVICE_DIR="$SWARM_DIR/lnd-$OWNER"
    mkdir -p "$SERVICE_DIR"
    HEX_MACAROON_FILE="$SERVICE_DIR/macaroon-$NET.hex"
    HEX_MACAROON="$( \
      docker exec -it "$CONTAINER" \
        xxd -p -c 1000 /root/.lnd/data/chain/bitcoin/$NET/admin.macaroon \
        | tr -d '\r' \
        | tr -d '\n' \
        || true
      )"
    case "$HEX_MACAROON" in
      *"No such file or directory"*)
        echo "ignoring macaroon => $HEX_MACAROON_FILE"
        ;;
      *)
        echo "creating macaroon => $HEX_MACAROON_FILE"
        echo -n "$HEX_MACAROON" | sed 's/^M$//' > "$HEX_MACAROON_FILE"
        ;;
    esac
    KEY_FILE="$SERVICE_DIR/pubkey-$NET.hex"
    if [ -n "${CONTAINER}" ]; then
      PUB_KEY="$( \
        docker exec -it "$CONTAINER" lncli --network="$NET" getinfo \
        | jq -r '.identity_pubkey' 2>/dev/null \
        || true )"
      if [ -n "${PUB_KEY}" ]; then
        echo "creating pubkey ==> $KEY_FILE"
        echo -n "$PUB_KEY" > "$KEY_FILE"
      else
        echo "ignoring pubkey ==> $KEY_FILE"
      fi
    fi
  done
done
