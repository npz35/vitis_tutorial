#!/bin/bash

docker build \
  --build-arg USER_NAME=$USER \
  --build-arg USER_UID=$(id -u) \
  --build-arg VERSION=2021.1 \
  -f Dockerfile \
  -t kv260/petalinux-builder:20.04 \
  .
