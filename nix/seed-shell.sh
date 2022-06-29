#!/bin/sh

set -e

nix-shell --pure -p '(import (fetchTarball { url = "https://github.com/coingaming/src/tarball/ef7ed491e5102063763538bc4cb2e86bc8021973"; sha256 = "1ml6jrz605jx7pmzd38d1490n8cbjv8yaclpqy57j7lqp1raaa7w"; } + "/nix/project.nix")).nixBitcoin.lndinit'
