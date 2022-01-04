#!/bin/sh

nix-build ./nix/docker.nix --option sandbox false  -v --show-trace
