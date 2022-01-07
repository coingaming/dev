# btc-lsp

Bitcoin Lightning Service Provider. Nix or Docker/Swarm is the only program required to get started. Development environment is packed into nix-shell.

## Docker/Swarm

To spawn `btc-lsp` running [Docker/Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) is required. On Mac you also need `brew install coreutils`.

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
