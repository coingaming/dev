#!/bin/sh

ROOT_DIR="$(pwd)"
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"
BTC_LSP_DIR="$SHELL_DIR/btc-lsp"
LND_LSP_DIR="$SHELL_DIR/lnd-lsp"
LND_ALICE_DIR="$SHELL_DIR/lnd-alice"
LND_BOB_DIR="$SHELL_DIR/lnd-bob"
BTCD_DIR="$SHELL_DIR/bitcoind"
BTCD2_DIR="$SHELL_DIR/bitcoind2"
PGDATA="$SHELL_DIR/postgres"

export GODEBUG=x509ignoreCN=0

#
# bitcoind
#

alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18443"
alias bitcoin-cli-2="bitcoin-cli -rpcwait -datadir=$BTCD2_DIR -rpcport=21001"

#
# lnd
#

alias lncli-lsp="lncli -n regtest --rpcserver 127.0.0.1:10010 --lnddir=$LND_LSP_DIR"
alias lncli-alice="lncli -n regtest --rpcserver 127.0.0.1:10011 --lnddir=$LND_ALICE_DIR"
alias lncli-bob="lncli -n regtest --rpcserver 127.0.0.1:10012 --lnddir=$LND_BOB_DIR"

lncli_lsp() {
  lncli -n regtest --rpcserver 127.0.0.1:10010 --lnddir=$LND_LSP_DIR $@
}

lncli_alice() {
  lncli -n regtest --rpcserver 127.0.0.1:10011 --lnddir=$LND_ALICE_DIR $@
}

lncli_bob() {
  lncli -n regtest --rpcserver 127.0.0.1:10012 --lnddir=$LND_BOB_DIR $@
}

export lncli_src_lsp="lncli -n regtest --rpcserver 127.0.0.1:10010 --lnddir=$LND_LSP_DIR"
export lncli_src_alice="lncli -n regtest --rpcserver 127.0.0.1:10011 --lnddir=$LND_ALICE_DIR"
export lncli_src_bob="lncli -n regtest --rpcserver 127.0.0.1:10012 --lnddir=$LND_BOB_DIR"

#
# app
#

export LSP_LND_ENV="
{
    \"lnd_wallet_password\":\"developer\",
    \"lnd_tls_cert\":\"$(cat "$LND_LSP_DIR/tls.cert" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')\",
    \"lnd_hex_macaroon\":\"0201036c6e6402f801030a10f65286e21207df41cc77be0175cbb2871201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e6572617465120472656164000006202eba3f3acaa7a7b974fdccc7a10060ede5b4801a85661c58166b062412e92e8a\",
    \"lnd_host\":\"127.0.0.1\",
    \"lnd_port\":10010,
    \"lnd_cipher_seed_mnemonic\":[
                  \"absent\",
                  \"dilemma\",
                  \"mango\",
                  \"firm\",
                  \"hero\",
                  \"green\",
                  \"wide\",
                  \"rebel\",
                  \"pigeon\",
                  \"custom\",
                  \"town\",
                  \"stadium\",
                  \"shock\",
                  \"bind\",
                  \"ocean\",
                  \"seek\",
                  \"enforce\",
                  \"during\",
                  \"bird\",
                  \"honey\",
                  \"enrich\",
                  \"number\",
                  \"wealth\",
                  \"thunder\"
                  ],
    \"lnd_aezeed_passphrase\":\"developer\"
}
"

export LND_ALICE_ENV="
{
  \"lnd_wallet_password\":\"developer\",
  \"lnd_tls_cert\":\"$(cat "$LND_ALICE_DIR/tls.cert" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')\",
  \"lnd_hex_macaroon\":\"0201036c6e6402f801030a10f65286e21207df41cc77be0175cbb2871201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e6572617465120472656164000006202eba3f3acaa7a7b974fdccc7a10060ede5b4801a85661c58166b062412e92e8a\",
  \"lnd_host\":\"127.0.0.1\",
  \"lnd_port\":10011,
  \"lnd_cipher_seed_mnemonic\":[
               \"absent\",
               \"betray\",
               \"direct\",
               \"scheme\",
               \"sunset\",
               \"mechanic\",
               \"exhaust\",
               \"suggest\",
               \"boy\",
               \"arena\",
               \"sketch\",
               \"bone\",
               \"news\",
               \"south\",
               \"way\",
               \"survey\",
               \"clip\",
               \"dutch\",
               \"depart\",
               \"green\",
               \"furnace\",
               \"wire\",
               \"wave\",
               \"fall\"
                ]
}
"

export LSP_LOG_ENV="dev"
export LSP_LOG_FORMAT="Bracket" # Bracket | JSON
export LSP_LOG_VERBOSITY="V3" # V0-V3
#
# Minimal severity level to log
#
# DebugS
# InfoS
# NoticeS
# WarningS
# ErrorS
# CriticalS
# AlertS
# EmergencyS
#
export LSP_LOG_SEVERITY="ErrorS"
export LSP_LOG_SECRET="SecretVisible" # SecretHidden | SecretVisible
export LSP_LND_P2P_HOST="127.0.0.1"
export LSP_LND_P2P_PORT="9736"
export LSP_MIN_CHAN_CAP_MSAT="20000000"
export LSP_MSAT_PER_BYTE="1000"
export LSP_LIBPQ_CONN_STR="postgresql://postgres@localhost/lsp-test"

#
# gRPC
#

export GRPC_TLS_KEY="$(cat "$BTC_LSP_DIR/key.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export GRPC_TLS_CERT="$(cat "$BTC_LSP_DIR/cert.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"

export LSP_GRPC_CLIENT_ENV="
{
  \"host\":\"127.0.0.1\",
  \"port\":8444,
  \"sig_header_name\":\"sig-bin\",
  \"compress_mode\":\"Compressed\"
}
"

#
# NOTE : for local swarm tests
#
# export LSP_GRPC_CLIENT_ENV="
# {
#   \"host\":\"yolo_btc-lsp\",
#   \"port\":443,
#   \"sig_header_name\":\"sig-bin\",
#   \"compress_mode\":\"Compressed\"
# }
# "
#
# TODO : remove this temporary mapping, which
# is workaround to avoid strange data: end of file
# error,  probably caused by docker-proxy, but only
# with Swift client (Haskell client works)
#
# export LSP_GRPC_CLIENT_ENV="
# {
#   \"host\":\"127.0.0.1\",
#   \"port\":8081,
#   \"sig_header_name\":\"sig-bin\"
# }
# "
#
# NOTE : for local k8s tests
#
# export LSP_GRPC_CLIENT_ENV="
# {
#   \"host\":\"btc-lsp\",
#   \"port\":30443,
#   \"sig_header_name\":\"sig-bin\",
#   \"compress_mode\":\"Compressed\"
# }
# "
#
# NOTE : for testnet DO k8s tests
#
# export LSP_GRPC_CLIENT_ENV="
# {
#   \"host\":\"testnet-lsp.coins.io\",
#   \"port\":8443,
#   \"sig_header_name\":\"sig-bin\",
#   \"compress_mode\":\"Compressed\"
# }
# "

export LSP_GRPC_SERVER_ENV="
{
  \"port\":8444,
  \"sig_verify\":true,
  \"sig_header_name\":\"sig-bin\",
  \"encryption\":\"Encrypted\",
  \"tls\":{
    \"cert\":\"$GRPC_TLS_CERT\",
    \"key\":\"$GRPC_TLS_KEY\"
  }
}
"

export LSP_ELECTRS_ENV="
{
  \"host\":\"127.0.0.1\",
  \"port\":\"60401\"
}
"

export LSP_BITCOIND_ENV="
{
  \"host\":\"http://localhost:18443\",
  \"username\":\"developer\",
  \"password\":\"developer\"
}
"

export LSP_BITCOIND_ENV2="
{
  \"host\":\"http://localhost:21001\",
  \"username\":\"developer\",
  \"password\":\"developer\"
}
"
