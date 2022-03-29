#!/bin/sh

LOCALHOST=127.0.0.1
HOSTS_FILE=/etc/hosts

if [ `uname -s` = "Darwin" ]; then
  IP_ADDRESS="$LOCALHOST"
else
  IP_ADDRESS="$1"
fi

setup () {
  ENTRY="$IP_ADDRESS $1"
  echo "Adding $ENTRY to $HOSTS_FILE"
#  grep -q "$ENTRY" /etc/hosts || echo "$ENTRY" >> $HOSTS_FILE
}

for SERVICE in lnd rtl lsp; do
  setup $SERVICE
done
