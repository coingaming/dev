# btc-lsp

Bitcoin Lightning Service Provider. Development environment is packed into nix-shell.

## Docker/Swarm

To spawn `btc-lsp` running [Docker/Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) is required. On Mac you also need `brew install coreutils` and `brew install expect`. Also make sure Docker have access to reasonable amount of resources (at least 8GB of memory, reasonable storage and CPU capacity). Initial compilation will take a lot of time, CPU, memory, bandwidth and storage, but it's needed to be done only once.

```sh
sudo ./nix/ds-setup-hosts.sh

./nix/ds-setup.sh

docker service ls

curl -d '' -v --cacert ./build/swarm/btc-lsp/cert.pem https://yolo_btc-lsp:443/BtcLsp.Service/SwapIntoLn
```

In case where you don't have initialized docker swarm (for example you never used it), you need to run:

```sh
./nix/ds-setup.sh --reset-swarm
```

Please keep in mind, flag `--reset-swarm` will probably kill all already existing swarm services.

## Auth

Every `btc-lsp` gRPC request/response does have `ctx` (context) field in payload which contains credentials:

- First is `nonce`.  The nonce is used for security reasons and is used to guard against replay attacks. The server will reject any request that comes with an incorrect nonce. The only requirement for the nonce is that it needs to be strictly increasing. Nonce generation is often achieved by using the current UNIX timestamp.
- Second is `ln_pub_key`. This is lightning node network identity public key in DER format. This key is used to verify request/response signature from headers/trailers.

Also every request/response does have a signature:

- Request/response signature is compact, DER-encoded and uses double-sha256 hash. It's located in `compact-2xsha256-sig` header/trailer.

## Haskell/Nix

Spawn shell:

```sh
# If you have Nix installed (a bit faster)
./nix/hm-shell-native.sh

# If you have Docker installed (works on Mac)
./nix/hm-shell-docker.sh
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
