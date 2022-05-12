{
  aliceCerts,
  lspCerts,
  prjSrc,
  dataDir,
  runCommand,
  openssl,
  writeText,
  writeScriptBin,
  lib
}: let
  serviceName = "btc-lsp";
  tlscerts = runCommand "lsp-tls-certs" {
    buildInputs = [ openssl ];
  } ''
    echo "subjectAltName=IP:127.0.0.1,DNS:localhost,DNS:127.0.0.1,DNS:${serviceName}" > subjectAltName
    openssl genrsa -out btc_lsp_tls_key.pem 2048
    openssl req -new -key btc_lsp_tls_key.pem \
      -out csr.csr -subj "/CN=${serviceName}/O=${serviceName}"
    openssl x509 -req -in csr.csr \
      -extfile "./subjectAltName" \
      -signkey btc_lsp_tls_key.pem -out btc_lsp_tls_cert.pem
    rm csr.csr
    rm subjectAltName
    mkdir -p $out
    mv ./btc_lsp_tls_key.pem $out/key.pem
    mv ./btc_lsp_tls_cert.pem $out/cert.pem
  '';
  lndEnv = {lndPort, cert, mnemonic, aezeed} : ''
    {
    \"lnd_wallet_password\":\"developer\",
    \"lnd_tls_cert\":\"$(cat "${cert}/tls.cert" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')\",
    \"lnd_hex_macaroon\":\"0201036c6e6402f801030a10f65286e21207df41cc77be0175cbb2871201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e6572617465120472656164000006202eba3f3acaa7a7b974fdccc7a10060ede5b4801a85661c58166b062412e92e8a\",
    \"lnd_host\":\"127.0.0.1\",
    \"lnd_port\":${toString lndPort},
    \"lnd_cipher_seed_mnemonic\":[${mnemonic}]
    ${lib.optionalString aezeed '',\"lnd_aezeed_passphrase\":\"developer\"''}
  }
  '';
lspLndEnv = lndEnv {
  aezeed = true;
  lndPort=10010;cert=lspCerts;mnemonic=''
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
'';};
aliceLndEnv = lndEnv {
  aezeed = false;
  lndPort=10011;cert=aliceCerts;mnemonic=''
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
'';};
setup = writeScriptBin "setup" ''
  cp --no-preserve=mode,ownership -R ${prjSrc}/btc-lsp/config/ ${dataDir}/
  cp --no-preserve=mode,ownership -R ${prjSrc}/btc-lsp/static/ ${dataDir}/
'';
exportEnvFile = writeText "export-lsp-env" ''
  export GODEBUG=x509ignoreCN=0
  export LSP_LND_ENV="${lspLndEnv}"
  export LND_ALICE_ENV="${aliceLndEnv}"
  export LSP_LOG_ENV="dev"
  export LSP_LOG_FORMAT="Bracket"
  export LSP_LOG_VERBOSITY="V3"
  export LSP_LOG_SEVERITY="EmergencyS"
  export LSP_LND_P2P_HOST="127.0.0.1"
  export LSP_LND_P2P_PORT="9736"
  export LSP_MIN_CHAN_CAP_MSAT="20000000"
  export LSP_MSAT_PER_BYTE="1000"
  export LSP_LIBPQ_CONN_STR="postgresql://postgres@localhost/lsp-test"
  export GRPC_TLS_KEY="$(cat "${tlscerts}/key.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
  export GRPC_TLS_CERT="$(cat "${tlscerts}/cert.pem" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')"
  export LSP_GRPC_CLIENT_ENV="
  {
    \"host\":\"127.0.0.1\",
    \"port\":8444,
    \"sig_header_name\":\"sig-bin\",
    \"compress_mode\":\"Compressed\"
  }
  "
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
  }"
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
'';
in {
  inherit exportEnvFile setup;
}
