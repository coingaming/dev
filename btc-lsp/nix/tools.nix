let nixpkgs = builtins.fetchTarball {
      url="https://github.com/NixOS/nixpkgs/archive/5dbd4b2b27e24eaed6a79603875493b15b999d4b.tar.gz";
      sha256="0f6514l8jva85v1g1vvib93691pwr25blzxr4i4vavys5dz6kxnm";
    };
    pkgs = import nixpkgs {};
in
with pkgs;
{
  inherit awscli2
          eksctl
          kubectl
          wget
          minikube
          doctl
          jq
          expect;
}
