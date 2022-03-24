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

Also every request/response does have a signature which is:

- Signed with LN identity key (key locator family is 6 and index is 0).
- Signed over binary request payload in exact gRPC/http2 wire [format](https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md) (1 byte of compression flag + 4 bytes of payload length in big endian format + payload bytes).
- Single hashed (double_hash parameter is False).
- Not compact (compact_sig parameter is False).
- Using DER binary format.
- Base64-encoded according official http2 [spec](https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md).
- Located in `sig-bin` gRPC header/trailer.

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

## Kubernetres

K8S setup is scripted in a way similar to Docker/Swarm setup. Some tools are required to be installed directly on host machine. They can be installed using nix-env:

```sh
./nix/nix-install-tools.sh
```

If nix is not available, install tools in any other way you like:

```
doctl-1.71.1
kubectl-1.23.5
minikube-1.25.2
jq-1.6
```

1. Setup cluster and services:

```sh
./nix/k8s-setup-cluster.sh
./nix/k8s-setup.sh --prebuilt
```

2. Forward services to localhost (MacOS):

```sh
minikube tunnel
```

## Digitalocean

1. Install (non nix) and configure doctl:

https://docs.digitalocean.com/reference/doctl/how-to/install/

2. Get cluster ID:

```sh
doctl k cluster get testnet-cluster
```

3. Setup kubecontext:

```sh
doctl kubernetes cluster kubeconfig save <cluster-id>
```

## Troubleshoot

1. Get list of running pods:

```sh
kubectl get po
```

2. Get info about pod:

```sh
kubectl describe pod <pod-name>
```

3. Get detailed info about current cluster state:

```sh
minikube dashboard
```

4. To access postgres dbs from local machine (pgAdmin or Postico):

```sh
kubectl port-forward <pod-name> 5432:<desired-port>
```

5. Lnd after restart is locked. Usually Lsp unlocks it automatically, but if for some reason it's locked (for example Lsp is not running) then it's possible to unlock Lnd with:

```sh
./nix/k8s-lazy-init-unlock.sh
```
