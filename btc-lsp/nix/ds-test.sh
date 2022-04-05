#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SHELL_DIR="$BUILD_DIR/shell"
LND_ALICE_DIR="$SHELL_DIR/lnd-alice"
LND_BOB_DIR="$SHELL_DIR/lnd-bob"

run_test() {
  echo "==> Loading integration docker image"
  IMAGE=$(docker load -q -i "$BUILD_DIR/docker-image-integration.tar.gz" \
    | awk '{print $NF}' \
    | tr -d '\n')

  LSP_AGENT_PRIVATE_KEY_PEM="$(cat "$BUILD_DIR/esdsa.prv" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
  LSP_PARTNER_PUBLIC_KEY_PEM="$(cat "$BUILD_DIR/esdsa.pub" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
  echo "$LSP_AGENT_PRIVATE_KEY_PEM"

  LSP_GRPC_CLIENT_ENV="
  {
    \"host\":\"localhost\",
    \"port\":41949,
    \"prv_key\":\"$LSP_AGENT_PRIVATE_KEY_PEM\",
    \"pub_key\":\"$LSP_PARTNER_PUBLIC_KEY_PEM\",
    \"sig_header_name\":\"sig-bin\",
    \"compress_mode\":\"Compressed\"
  }
  "
  echo "$LSP_GRPC_CLIENT_ENV"

  LSP_BITCOIND_ENV="
  {
    \"host\":\"http://bitcoind:18443\",
    \"username\":\"bitcoinrpc\",
    \"password\":\"developer\"
  }
  "

  LSP_GRPC_SERVER_ENV="
  {
    \"port\":443,
    \"sig_verify\":true,
    \"sig_header_name\":\"sig-bin\",
    \"tls_cert\":\"-----BEGIN CERTIFICATE-----\nMIIDFjCCAf6gAwIBAgIUPwNHk3M+qO9Au/PRL9232tXkzEkwDQYJKoZIhvcNAQEL\nBQAwJDEQMA4GA1UEAwwHYnRjLWxzcDEQMA4GA1UECgwHYnRjLWxzcDAeFw0yMjAz\nMjExMjU2MzNaFw0yMjA0MjAxMjU2MzNaMCQxEDAOBgNVBAMMB2J0Yy1sc3AxEDAO\nBgNVBAoMB2J0Yy1sc3AwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0\nriGSwU8f1okSYOpwSGR78etWLkCIJ6iOT51f+iOXV4DSHHHamOGsdI4ElJmiaNc3\nK7Wqiw1r6fVjhkj91DXpJm/cMtgu8KUSJpvtcNPg5xREsTudMqu7snbsiivICAUG\na/WGq50bmedaCKYC42QD3H4P9l51qg6aJEmRnNwyBUInY1ULcAM99pdITZNE2aHj\nZ1x+36ipIwkJfMUgrXw4hmy6ldNAwiahaQ6xUm7bxNI64MjoYehq+mmOEd+LCK2j\nILlzbMk7Q8YGc2s1B2gau3NixEz/DXjfmzidwaLq/AsPA7jCr8glICSe1hjaNFYS\nn24EXWNhu+5rrzREQRF1AgMBAAGjQDA+MDwGA1UdEQQ1MDOHBH8AAAGCCWxvY2Fs\naG9zdIIJMTI3LjAuMC4xggdidGMtbHNwggx5b2xvX2J0Yy1sc3AwDQYJKoZIhvcN\nAQELBQADggEBAI9zAJtQfgq7w/lYWFm2LzW8WfH9UMaKo3gDC21/2LPs8Q6Xy6Cb\nky9ExFm4OCO13RJNBpL4Ss+ahjbWWX25bTWKmcHIlk58Ju1JCUkgJed4DrBmCDpk\nzc0rsRL+24XOr6nqNjDfGisDam4BOry6dQuaCwAwhEUhvC9RiAsAqyyGA9B649Gv\n4ZDSUCVnjBM3FscK/vSY5Mk5afTbG9AH+5GIII8x8fV6W/AJm75vgP7tb5dvs0NY\nQ0LIfiGzUm4/beP+y9tPnJsfXe/QidyA/FuvEhZomIVa1ApjB/ki+uj7tnwWsyTM\nqis6LwuzHWofuSUnKw7Ciy83v7uodm0cdgs=\n-----END CERTIFICATE-----\n\",
    \"tls_key\":\"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAtK4hksFPH9aJEmDqcEhke/HrVi5AiCeojk+dX/ojl1eA0hxx\n2pjhrHSOBJSZomjXNyu1qosNa+n1Y4ZI/dQ16SZv3DLYLvClEiab7XDT4OcURLE7\nnTKru7J27IoryAgFBmv1hqudG5nnWgimAuNkA9x+D/ZedaoOmiRJkZzcMgVCJ2NV\nC3ADPfaXSE2TRNmh42dcft+oqSMJCXzFIK18OIZsupXTQMImoWkOsVJu28TSOuDI\n6GHoavppjhHfiwitoyC5c2zJO0PGBnNrNQdoGrtzYsRM/w1435s4ncGi6vwLDwO4\nwq/IJSAkntYY2jRWEp9uBF1jYbvua680REERdQIDAQABAoIBAHEy983eVxh3bQGa\nvscCVBJjizI/YCbt0ej3cH4FVe8n34nEUIDIb/uAOsob3/WlAdGLDRKAdDQ8LIXi\nSDDfl7cvYb3wDQm7s3AfyGmG2vh5TnWLJPJkILxEH8Yq+ysj+yH+2aE6PABi+FOs\nP3ZnyO2yYzjU/nFxzhw8x+r2/+5F15aRo+3hawXwF1kE3lq1CS8Tj1K6bMYNu2SW\njbAaGNN+vttgyPA9BjGFg+/3xgjb3nDDBTK8h5vNcPDYBEeiQn1mfwHlyZY+h7e3\ndBiZoek26rycg8cLh0F9twrRBb6TmNqHkifXfN1smTUpM7IS80GiDKN/iF9B9Gdd\n5mFXYrECgYEA2y0JZ3Eo9hS2voFMTn9GT3O2liP1ftVs4aL0ycuFK1WLe0Qb151O\nshhCv2WYJ8l9D20pmkQwznf/KuweFTm6GZvAI2zsYuQQ5RRL0uR8VIrjH7EJHDFG\nWmeUayc0WfYGWoEH1lRCqbZDdPDx1bq72P91SrYRW/G/MZEhynlTsDcCgYEA0wlb\nYku1//jsRI6qiMiMClyOvi+PQ2+9bVcbTs/vH/I4gNMT4Vild8lxypXl+8BX7QWF\nKsPNx3kyeuvQ5Lr1SHDDirm76F96UShtZpXwI5R6gZwwQJ4yxE6/DKfOZcOYy4aG\nRHIbY5ViRMd9NVxuJ83s7FSUoKvAdkSN4E7efbMCgYBJ6MIHE+3QLeQCEe/9eIXp\nPQgRUUbz4ly5Kg6KDgt2NX63rpwE9ZMYE35OtJ++qv91OEaTMvOSbHyrqLvsRG8x\nO4hracu8/VOFLHb1Qv96MuusQDLmQueKjOtLxwisXX5+/ov6BqgEOuY8hRPIExRN\ndLfE3ei0rKzgtiRC9u71uQKBgQDMJ7koFmYzAvROPlXrjVcsju3oPsoxSt/N7v6T\n98Q0+3Z96bTJw6APielzOiAKs8Bbo4N4I4Pm/PBAyfCD1fmD4tLIWXXXDsadzKZJ\nH7P4N6Nrz1U+rcwe7K8V5yBcgiRGgBVUEa89Xz55myMdhBVsnGIfHpPJ+11tDFTU\nMng60QKBgQCcqQZI4RB2kHi26cnnxxMh5oNlaHU4tDoa3hR49j39nGo6rnnatZa2\nMkK2bhCQJzYfFZ1uAZ4Ihdplm7Wa1Lp1ALWJbRfS38chqUaao5bIh+guGbPMGFu3\nXyDXX8hQtBYYkfByfs5VcTL8MI3+xqT85U85trEx+QXvVzAbI9KCRA==\n-----END RSA PRIVATE KEY-----\n\"
  }
  "
  LND_LSP_ENV="
  {
    \"lnd_wallet_password\":\"developer\",
    \"lnd_tls_cert\":\"-----BEGIN CERTIFICATE-----\r\nMIICKzCCAdGgAwIBAgIRAPGIWYRbT2H/Mo5nGwVhOYcwCgYIKoZIzj0EAwIwMzEf\r\nMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEQMA4GA1UEAxMHbG5kLWxz\r\ncDAeFw0yMjAzMjIwNzQxMzNaFw0yMzA1MTcwNzQxMzNaMDMxHzAdBgNVBAoTFmxu\r\nZCBhdXRvZ2VuZXJhdGVkIGNlcnQxEDAOBgNVBAMTB2xuZC1sc3AwWTATBgcqhkjO\r\nPQIBBggqhkjOPQMBBwNCAAQNzASC53z79ipgYpV6rAkyNah39mewMkfLCdKYqKcO\r\n0r95IAccVUXbEesiDM+kYy8BKDPD7QcGiVXadEZisS7Po4HFMIHCMA4GA1UdDwEB\r\n/wQEAwICpDATBgNVHSUEDDAKBggrBgEFBQcDATAPBgNVHRMBAf8EBTADAQH/MB0G\r\nA1UdDgQWBBQyGZe/f8FQVZxXSpmPPXjuQtqhcjBrBgNVHREEZDBiggdsbmQtbHNw\r\ngglsb2NhbGhvc3SCB2xuZC1sc3CCBHVuaXiCCnVuaXhwYWNrZXSCB2J1ZmNvbm6H\r\nBH8AAAGHEAAAAAAAAAAAAAAAAAAAAAGHBAoAAFKHBKwSAAOHBAoAAWIwCgYIKoZI\r\nzj0EAwIDSAAwRQIhAMLckceLOdMoitOvkAihmPPLBKVCWZhO6h9tICVWD21RAiB5\r\nwVlLqXvSGwFirTqlvAwMxPGc+BaiA0yWC/gvMWNQJQ==\r\n-----END CERTIFICATE-----\r\n\",
    \"lnd_hex_macaroon\":\"0201036c6e6402f801030a1068491e2164f2f9d62faa8a59a2eacf771201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e657261746512047265616400000620759162496146d8a851d203b38036022d081d50b3db87fe4151bf2b79c50762ea\",
    \"lnd_host\":\"localhost\",
    \"lnd_port\":41949,
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
  LSP_ELECTRS_ENV="
  {
    \"host\":\"electrs\",
    \"port\":\"80\"
  }
  "

  LSP_LOG_SEVERITY="DebugS"
  LSP_LND_P2P_HOST="127.0.0.1"
  LSP_LND_P2P_PORT="9735"
  LSP_LIBPQ_CONN_STR="postgresql://postgres@localhost/btc-lsp"
  LSP_LOG_ENV="test"
  LSP_LOG_FORMAT="Bracket" # Bracket | JSON
  LSP_LOG_VERBOSITY="V3" # V0-V3
  LSP_LOG_SEVERITY="DebugS"
  LSP_MIN_CHAN_CAP_MSAT="20000000"

  #IMAGE="heathmont/btc-lsp-integration:2nlrf3hb7rb7mpkx7rrda7cmx3w03393"

  #echo $IMAGE
  docker run \
    --env LSP_GRPC_CLIENT_ENV \
    --env LSP_BITCOIND_ENV \
    --env LSP_GRPC_SERVER_ENV \
    --env LSP_LND_ENV \
    --env LSP_ELECTRS_ENV \
    --env LSP_LIBPQ_CONN_STR \
    --env LSP_LND_P2P_HOST \
    --env LSP_LND_P2P_PORT \
    --env LSP_LOG_ENV \
    --env LSP_LOG_FORMAT \
    --env LSP_LOG_SEVERITY \
    --env LSP_LOG_VERBOSITY \
    --env LND_LSP_ENV \
    --env LSP_MIN_CHAN_CAP_MSAT \
    $IMAGE
}

forward_postgres() {
  kubectl port-forward service/postgres 5432:5432
  wait
}

#forward_postgres &
run_test

echo "Done"
#(kubectl port-forward service/lnd-lsp 2222:9735)

