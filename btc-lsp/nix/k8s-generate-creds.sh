#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SWARM_DIR="$THIS_DIR/../build/swarm"

for NET in regtest testnet mainnet; do
  for OWNER in lsp; do

    SERVICE="lnd-$OWNER"
    POD=`sh $THIS_DIR/k8s-get-pod.sh $SERVICE`
    SERVICE_DIR="$SWARM_DIR/lnd-$OWNER"
    mkdir -p "$SERVICE_DIR"

    #
    # TODO : NET is redundant there, move it level ubove it
    #

    echo "$SERVICE ==> LN tls cert"
    CERT_FILE="$SERVICE_DIR/tls.cert"
    if [ -n "${POD}" ]; then
      CERT="$( \
        kubectl exec -it "$POD" \
          -- cat /root/.lnd/tls.cert \
          || true
        )"
      if [ -n "${CERT}" ]; then
        echo "creating cert ==> $CERT_FILE"
        echo "$CERT" > "$CERT_FILE"
      else
        echo "ignoring cert ==> $CERT_FILE"
      fi
    fi

    echo "$SERVICE ==> LN macaroons"
    HEX_MACAROON_FILE="$SERVICE_DIR/macaroon-$NET.hex"
    HEX_MACAROON="$( \
      kubectl exec -it "$POD" \
        -- xxd -p -c 1000 /root/.lnd/data/chain/bitcoin/$NET/admin.macaroon \
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
        echo "$HEX_MACAROON" \
          | tr -d '\r' \
          | tr -d '\n' \
          > "$HEX_MACAROON_FILE"
        ;;
    esac

    echo "$SERVICE ==> LN identity pubkey"
    KEY_FILE="$SERVICE_DIR/pubkey-$NET.hex"
    if [ -n "${POD}" ]; then
      PUB_KEY="$( \
        kubectl exec -it "$POD" -- lncli --network="$NET" getinfo \
        | jq -r '.identity_pubkey' 2>/dev/null \
        || true )"
      if [ -n "${PUB_KEY}" ]; then
        echo "creating pubkey ==> $KEY_FILE"
        echo "$PUB_KEY" > "$KEY_FILE"
      else
        echo "ignoring pubkey ==> $KEY_FILE"
      fi
    fi

  done
done
