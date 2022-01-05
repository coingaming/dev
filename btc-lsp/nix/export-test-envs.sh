#!/bin/sh

export GODEBUG=x509ignoreCN=0
THIS_DIR="$(pwd)"

esc() {
  echo "$1" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g'
}

#
# bitcoind
#

export PGDATA="$PWD/postgres"
export BTCD_DIR="$THIS_DIR/.bitcoin"
alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18443"

#
# lnd
#

export LND_MERCHANT_DIR="$THIS_DIR/.lnd-merchant"
alias lncli-merchant="lncli -n regtest --lnddir=$LND_MERCHANT_DIR"
export LND_PAYMENTS_DIR="$THIS_DIR/.lnd-payments"
alias lncli-payments="lncli -n regtest --lnddir=$LND_PAYMENTS_DIR --rpcserver=localhost:11009"

#
# app
#

export LND_TLS_CERT="$(cat "$THIS_DIR/.lnd/tls.cert" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export LSP_MERCHANT_LND_ENV="
{
    \"lnd_wallet_password\":\"developer\",
    \"lnd_tls_cert\":\"$LND_TLS_CERT\",
    \"lnd_hex_macaroon\":\"0201036C6E6402CF01030A10634D5C8D3227E9F63529F82690C1898E1201301A160A0761646472657373120472656164120577726974651A130A04696E666F120472656164120577726974651A170A08696E766F69636573120472656164120577726974651A160A076D657373616765120472656164120577726974651A170A086F6666636861696E120472656164120577726974651A160A076F6E636861696E120472656164120577726974651A140A057065657273120472656164120577726974651A120A067369676E6572120867656E657261746500000620EB31C7413A5A44D14705852F8C0CA399104658C40AC866918C1D4B981DF2E71E\",
    \"lnd_host\":\"localhost\",
    \"lnd_port\":10009,
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
  \"lnd_hex_macaroon\":\"0201036C6E6402CF01030A10634D5C8D3227E9F63529F82690C1898E1201301A160A0761646472657373120472656164120577726974651A130A04696E666F120472656164120577726974651A170A08696E766F69636573120472656164120577726974651A160A076D657373616765120472656164120577726974651A170A086F6666636861696E120472656164120577726974651A160A076F6E636861696E120472656164120577726974651A140A057065657273120472656164120577726974651A120A067369676E6572120867656E657261746500000620EB31C7413A5A44D14705852F8C0CA399104658C40AC866918C1D4B981DF2E71E\",
  \"lnd_host\":\"localhost\",
  \"lnd_port\":11009,
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

export LSP_AGENT_PRIVATE_KEY_PEM="$(esc "
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIPr2CehwrgBUDoPOqKbm43nxNIBRgJkb60hJRxu7H0bloAcGBSuBBAAK
oUQDQgAEFVguhn0vM+U6x3HMnrMIO93YSzsuAWdnjokIOb+Ww1jTofrfg1ZuL+aZ
7yn6nC2zikABcBgk5DtS1QizlYcJ/A==
-----END EC PRIVATE KEY-----
")"

export LSP_PARTNER_PUBLIC_KEY_PEM="$(esc "
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEe96ofwc8cS+MEiRzkgIYfHYnCrouJZwu
S/0jIwsLJkf61mIl2tMViaZ4nWjrLyS7cQPZO2lW47NFHbF4q7bheA==
-----END PUBLIC KEY-----
")"

export GRPC_TLS_CERT="$(cat "$THIS_DIR/.grpc-tls/certificate.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export GRPC_TLS_KEY="$(cat "$THIS_DIR/.grpc-tls/key.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
export LSP_GRPC_CLIENT_ENV="
{
  \"host\":\"localhost\",
  \"port\":8443,
  \"prv_key\":\"$LSP_AGENT_PRIVATE_KEY_PEM\",
  \"pub_key\":\"$LSP_PARTNER_PUBLIC_KEY_PEM\",
  \"sig_header_name\":\"signable-secp256k1-signature\"
}
"
export LSP_GRPC_SERVER_ENV="
{
  \"port\":8443,
  \"prv_key\":\"$LSP_AGENT_PRIVATE_KEY_PEM\",
  \"pub_key\":\"$LSP_PARTNER_PUBLIC_KEY_PEM\",
  \"sig_header_name\":\"signable-secp256k1-signature\",
  \"tls_cert\":\"$GRPC_TLS_CERT\",
  \"tls_key\":\"$GRPC_TLS_KEY\"
}
"
