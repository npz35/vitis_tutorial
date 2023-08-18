#!/bin/bash

docker build \
  --build-arg USER_NAME=$USER \
  --build-arg USER_UID=$(id -u) \
  --build-arg VERSION=2023.1 \
  --build-arg VPP_PARALLEL=6 \
  -f Dockerfile \
  -t kv260/krs:0.4.0 \
  .
