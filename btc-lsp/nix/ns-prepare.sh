#!/bin/sh

./nix/ns-gen-cfgs.sh;
./nix/ns-gen-keys.sh;
. ./nix/ns-export-test-envs.sh;
./nix/ns-reset-test-data.sh;
./nix/ns-spawn-test-deps.sh;
