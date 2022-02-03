#!/bin/sh

ROOT_DIR="$(pwd)"
BUILD_DIR="$ROOT_DIR/build"
export GODEBUG=x509ignoreCN=0

#
# bitcoind
#

export PGDATA="$PWD/postgres"
export BTCD_DIR="$ROOT_DIR/.bitcoin"
alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18443"

#
# lnd
#

export LND_LSP_DIR="$ROOT_DIR/.lnd-lsp"
alias lncli-lsp="lncli -n regtest --lnddir=$LND_LSP_DIR --rpcserver=127.0.0.1:10010"
export LND_ALICE_DIR="$ROOT_DIR/.lnd-alice"
alias lncli-alice="lncli -n regtest --lnddir=$LND_ALICE_DIR --rpcserver=127.0.0.1:10011"

#
# app
#

export LND_TLS_CERT="$(cat "$ROOT_DIR/.lnd/tls.cert" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export LND_LSP_ENV="
{
    \"lnd_wallet_password\":\"developer\",
    \"lnd_tls_cert\":\"$LND_TLS_CERT\",
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

export LSP_LND_ENV="
{
  \"lnd_wallet_password\":\"developer\",
  \"lnd_tls_cert\":\"$LND_TLS_CERT\",
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
export LSP_LOG_SEVERITY="InfoS"
export LSP_LIBPQ_CONN_STR="postgresql://postgres@localhost/lsp-test"
export LSP_ENDPOINT_PORT="3000"

# 32 symbols for AES256
export LSP_AES256_SECRET_KEY="y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN"
# 16 symbols for AES256
export LSP_AES256_INIT_VECTOR="dRgUkXp2s5v8y/B?"

#
# gRPC
#

export LSP_AGENT_PRIVATE_KEY_PEM="$(cat "$BUILD_DIR/esdsa.prv" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export LSP_PARTNER_PUBLIC_KEY_PEM="$(cat "$BUILD_DIR/esdsa.pub" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"

export GRPC_TLS_CERT="$(cat "$BUILD_DIR/btc_lsp_tls_cert.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export GRPC_TLS_KEY="$(cat "$BUILD_DIR/btc_lsp_tls_key.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"

export LSP_GRPC_CLIENT_ENV="
{
  \"host\":\"127.0.0.1\",
  \"port\":8444,
  \"prv_key\":\"$LSP_AGENT_PRIVATE_KEY_PEM\",
  \"pub_key\":\"$LSP_PARTNER_PUBLIC_KEY_PEM\",
  \"sig_header_name\":\"compact-2xsha256-sig\"
}
"
export LSP_GRPC_SERVER_ENV="
{
  \"port\":8444,
  \"sig_header_name\":\"compact-2xsha256-sig\",
  \"tls_cert\":\"$GRPC_TLS_CERT\",
  \"tls_key\":\"$GRPC_TLS_KEY\"
}
"

export LSP_ELECTRS_ENV="
{
  \"host\":\"127.0.0.1\",
  \"port\":\"60401\"
}
"
