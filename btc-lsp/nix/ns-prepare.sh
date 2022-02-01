#!/bin/sh

./nix/ns-gen-cfgs.sh;
./nix/ns-gen-keys.sh;
. ./nix/export-test-envs.sh;
./nix/ns-reset-test-data.sh;
./nix/spawn-test-deps.sh;
