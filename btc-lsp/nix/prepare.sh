#!/bin/sh

./nix/nt-gen-cfgs.sh;
./nix/nt-gen-keys.sh;
. ./nix/export-test-envs.sh;
./nix/reset-test-data.sh;
./nix/spawn-test-deps.sh;
