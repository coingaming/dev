#!/bin/sh

set -e

kubectl rollout restart deploy "$1"
