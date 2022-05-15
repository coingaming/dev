{
  dataDir ? "./tmp"
, bitcoinDir
, name
, writeText
, writeShellScriptBin
, symlinkJoin
, runCommand
, openssl
, electrs
}:
let
  electrstoml = writeText "electrs.toml" ''
    auth="developer:developer"
    log_filters = "INFO"
  '';
  serviceName = "electrs-${name}";
  workDir = "${dataDir}/${serviceName}";
  setup = writeShellScriptBin "setup" ''
    mkdir -p "${workDir}/db"
    cp -f ${electrstoml} ${workDir}/electrs.toml
  '';
  start = writeShellScriptBin "start" ''
    ${electrs}/bin/electrs \
    --conf="${workDir}/electrs.toml" \
    --db-dir="${workDir}/db" \
    --daemon-dir="${bitcoinDir}" \
    --network=regtest \
    --electrum-rpc-addr="127.0.0.1:60401" \
    --daemon-rpc-addr="127.0.0.1:18443" \
    --timestamp \
    > ${workDir}/stdout.log 2>&1 &
    echo "$!" > "${workDir}/electrs.pid"
    echo "Started electrs"
  '';
  stop = writeShellScriptBin "stop" ''
    electrs_pid=`cat ${workDir}/electrs.pid`
    echo "Stoping electrs ${name} $electrs_pid"
    kill -9 "$electrs_pid"
  '';
  up = writeShellScriptBin "up" ''
    ${setup}/bin/setup
    ${start}/bin/start
  '';
  down = writeShellScriptBin "down" ''
    ${stop}/bin/stop
  '';
in {
  inherit up down;
}
