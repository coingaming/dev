{
  dataDir ? "./tmp"
, name
, writeText
, writeShellScriptBin
, runCommand
, postgresql
}:
let
  postgresqlconf = writeText "postgresql.conf" ''
    unix_socket_directories = '/tmp'
    log_statement = 'all'
  '';
  serviceName = "postgresql-${name}";
  workDir = "${dataDir}/${serviceName}";
  setup = writeShellScriptBin "setup" ''
    ${postgresql}/bin/initdb -D ${workDir} --auth=trust --no-locale --encoding=UTF8
    mkdir -p "${workDir}/sockets"
    cp -f ${postgresqlconf} ${workDir}/postgresql.conf
  '';
  init = writeShellScriptBin "init" ''
    ${postgresql}/bin/createuser -s postgres -h "/tmp"
    ${postgresql}/bin/createdb -h localhost lsp
    ${postgresql}/bin/createdb -h localhost lsp-test
  '';
  start = writeShellScriptBin "start" ''
    ${postgresql}/bin/pg_ctl -D ${workDir} -l ${workDir}/postgres.log start
  '';
  stop = writeShellScriptBin "stop" ''
    timeout 5 ${postgresql}/bin/pg_ctl -D ${workDir} stop
  '';
  up = writeShellScriptBin "up" ''
    ${setup}/bin/setup
    ${start}/bin/start
    ${init}/bin/init
  '';
  down = writeShellScriptBin "down" ''
    ${stop}/bin/stop
  '';
in {
  inherit up down;
}
