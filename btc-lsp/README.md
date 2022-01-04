# btc-lsp

Bitcoin Lightning Service Provider. Nix is the only program required to get started. Development environment is packed into nix-shell.

## Quickstart

Setup environment variables:

```sh
export VIM_BACKGROUND="light" # or "dark"
export VIM_COLOR_SCHEME="PaperColor" # or "jellybeans"
export GIT_AUTHOR_NAME="alice"
export GIT_AUTHOR_EMAIL="alice@heathmont.net"
#
# optional
#
export NIX_EXTRA_BUILD_INPUTS='[(import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/ebfcd25eeac74ba813efa0b5929174cd59c4f4d2") {bundle = "haskell"; withGit = false;})]'
export NIX_WITH_SHELL_HOOK="true"
```

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
