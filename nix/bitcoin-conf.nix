{
  name
, dataDir
, rpcport
, port
, rpcuser ? "developer"
, rpcpassword ? "developer"
, lib
, runCommand
, writeText
, symlinkJoin
, writeShellApplication
, writeShellScriptBin
, unixtools
, bitcoind
}:
let
  bitcoinconf = writeText "bitcoin.conf" ''
    regtest=1
    txindex=1
    mintxfee=0.00000001

    rpcuser=${rpcuser}
    rpcpassword=${rpcpassword}

    zmqpubrawblock=tcp://127.0.0.1:28332
    zmqpubrawtx=tcp://127.0.0.1:28333

    server=1
    rest=1
    fallbackfee=0.00000001
  '';
  getFreePort = writeShellApplication {
    name = "get-unused-port";
    runtimeInputs = [ unixtools.netstat ];
    text = ''
       while
         port=$(shuf -n 1 -i 49152-65535)
         netstat -atun | grep -q "$port"
      do
         continue
      done
      echo "$port"
    '';
  };
  workDir = "${dataDir}/bitcoind_${name}";
  start = writeShellScriptBin "start" ''
    echo "Start"
    ${bitcoind}/bin/bitcoind -port=${toString port} -rpcport=${toString rpcport} -datadir='${workDir}' > ${workDir}/stdout.log 2>&1 &
  '';
  init = writeShellScriptBin "init" ''
    echo "init"
    export PATH="${lib.makeBinPath [cli]}"
    bitcoin-cli createwallet "testwallet"
    bitcoin-cli generatetoaddress 1 "$(bitcoin-cli getnewaddress)"
    bitcoin-cli getblockchaininfo '';
  stop = writeShellScriptBin "stop" ''
    echo "Stop"
    bitcoin_pid=`cat ${workDir}/regtest/bitcoind.pid`
    timeout 5 ${cli}/bin/bitcoin-cli stop
    kill -9 "$bitcoin_pid"
    rm -rf ${workDir}
  '';
  setup = writeShellScriptBin "setup" ''
    echo "Setup"
    mkdir -p ${workDir}
    cp -f ${bitcoinconf} "${workDir}/bitcoin.conf"
  '';
  cli = writeShellScriptBin "bitcoin-cli" ''
    ${bitcoind}/bin/bitcoin-cli -rpcwait -datadir='${workDir}' -rpcport=${toString rpcport} "$@"
  '';
  up = writeShellScriptBin "up" ''
    pwd
    ${setup}/bin/setup
    ${start}/bin/start
    ${init}/bin/init
  '';
  down = writeShellScriptBin "down" ''
    ${stop}/bin/stop
  '';
in
{
  bitcoinDir = workDir;
  inherit up down cli;
}
