#!/bin/sh

set -e

(
  mkdir -p ~/Downloads
  cd ~/Downloads
  sudo apt-get install -y gnupg2 curl tar
  curl -o install-nix-2.3.10 \
    https://releases.nixos.org/nix/nix-2.3.10/install
  curl -o install-nix-2.3.10.asc \
    https://releases.nixos.org/nix/nix-2.3.10/install.asc
  gpg2 \
    --keyserver hkps://keyserver.ubuntu.com \
    --recv-keys B541D55301270E0BCF15CA5D8170B4726D7198DE
  gpg2 --verify ./install-nix-2.3.10.asc
  sh ./install-nix-2.3.10
)
