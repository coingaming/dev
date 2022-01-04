#!/bin/sh

nix-build --option sandbox false  -v --show-trace
