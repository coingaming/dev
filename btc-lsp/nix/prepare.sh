#!/bin/sh

./nix/generate-tls-cert.sh;
. ./nix/export-test-envs.sh;
./nix/reset-test-data.sh;
./nix/spawn-test-deps.sh;
