# btc-lsp

Bitcoin Lightning Service Provider. Development environment is packed into nix-shell.

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

Run tests with hot code reloading:

```sh
./nix/ns-ghcid-test.sh
```

Run app with hot code reloading:

```sh
./nix/ns-ghcid-main.sh
```

## Release

Releases are automated by CI. To create new release, bump the version inside `VERSION` file. Then push all changes into github and merge into `master` branch. Then run:

```sh
../nix/hm-release.sh
```

The script will push new tag which will trigger new github release and package.

## Kubernetes

Some tools are required to be installed directly on host machine. They can be installed using nix-env:

```sh
./nix/nix-install-tools.sh
```

If nix is not available, install tools in any other way you like:

```
expect-5.45.4
jq-1.6
kubectl-1.23.5
minikube-1.25.2
wget-1.21.3
```

### Regtest setup

1. Setup minikube cluster and deploy k8s resources:

```sh
./nix/mk-deploy-regtest.sh
```

2. Forward services to host network:

```sh
./nix/k8s-forward.sh
```

### Service/config upgrade

1. Set k8s context to upgrade

```sh
kubectl config use-context <ctx-name>
```

2. Upgrade services/configs

```sh
./nix/k8s-upgrade.sh <net> <mode> <services>
```

Example

```sh
./nix/k8s-upgrade.sh --regtest --prebuilt lsp bitcoind
```

## Testnet setup (DigitalOcean)

1. Install and configure doctl:

If you have used nix-env doctl will already be installed, otherwise install it manually.

```
doctl-1.71.1
```

Follow the guide below to configure `doctl`.

https://docs.digitalocean.com/reference/doctl/how-to/install/

1. Setup LetsEncrypt, Managed Kubernetes, Managed Postgres and deploy k8s resources:

```sh
./nix/d-deploy-testnet.sh
```

2. Create A-records within your DNS provider for created LoadBalancers and Ingress controller:


```
testnet-bitcoind.yourdomain.com
testnet-lnd.yourdomain.com
testnet-rtl.yourdomain.com
testnet-lsp.yourdomain.com
```

Get IPs of LoadBalancers:

```sh
kubectl get svc
```

Get IP of Ingress:

```sh
kubectl get ingress
```

## Testnet setup (AWS)

1. Install aws cli, eksctl and helm:

If you have used nix-env everything will be already installed, otherwise install manually.

```
aws-cli-2.5.4
eksctl-0.93.0
helm-3.8.2
```

2. Create IAM user with `AdministratorAccess` in AWS Console

3. Configure aws cli `access_key_id`, `secret_access_key`, `region`

```sh
aws configure
```

4. Setup EKS, RDS, Route53, ACM and deploy k8s resources:

```sh
./nix/aws-deploy-testnet.sh
```

5. Completely remove deployed testnet setup

```sh
./nix/aws-destroy-testnet.sh
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

3. Get detailed info about current cluster state (regtest only):

```sh
minikube dashboard --profile=btc-lsp
```

4. Lnd after restart is locked. Usually Lsp unlocks it automatically, but if for some reason it's locked (for example Lsp is not running) then you can unlock it with:

```sh
./nix/k8s-lazy-init-unlock.sh
```

5. Delete all failed Pods

```sh
kubectl delete pod --all-namespaces --field-selector 'status.phase=Failed'
```

6. Connect to existing cluster on DigitalOcean:

Get cluster ID

```sh
doctl k cluster get lsp-testnet
```

Add context to kube config

```sh
doctl kubernetes cluster kubeconfig save <cluster-id>
```

7. Connect to existing eks cluster on AWS:

```sh
aws eks update-kubeconfig --name lsp-testnet
```

8. Manage k8s contexts:

Display list of contexts

```sh
kubectl config get-contexts
```

Display the current context

```sh
kubectl config current-context
```

Set current context to btc-lsp

```sh
kubectl config use-context btc-lsp
```

9. List k8s nodes

```sh
kubectl get nodes -o wide
```

10. Get current storage class

```sh
kubectl get storageclass
```
