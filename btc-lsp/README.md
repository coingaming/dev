# btc-lsp

Bitcoin Lightning Service Provider. Nix is the only program required to get started. Development environment is packed into nix-shell.

## Quickstart

Spawn shell:

```sh
./nix/shell.sh
```

Develop in shell:

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
