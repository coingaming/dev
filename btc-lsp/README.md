# btc-lsp

Bitcoin Lightning Service Provider. Nix or Docker/Swarm is the only program required to get started. Development environment is packed into nix-shell.

## Docker/Swarm

To spawn `btc-lsp` running [Docker/Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) is required. On Mac you also need `brew install coreutils`. Also make sure Docker have access to reasonable amount of resources (at least 8GB of memory, reasonable storage and CPU capacity). Initial compilation will take a lot of time, CPU, memory, bandwidth and storage, but it's needed to be done only once.

```sh
./nix/ds-setup.sh

docker service ls

curl -d '' -v --cacert ./build/btc_lsp_tls_cert.pem https://127.0.0.1:8443/BtcLsp.Service/CustodyDepositLn
```

## Haskell/Nix

Spawn shell:

```sh
# If you have Nix installed (a bit faster)
./nix/shell-native.sh

# If you have Docker installed (works on Mac)
./nix/shell-docker.sh
```

Work with Haskell sources in shell:

```sh
vi .
```

Run all tests with hot code reloading:

```sh
ghcid
```

Run specific tests with hot code reloading:

```sh
ghcid --setup ":set args -m importPubKey"
```
