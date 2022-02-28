#!/bin/sh

set -e

DEPLOYMENT="$1"

kubectl rollout restart deploy $DEPLOYMENT
