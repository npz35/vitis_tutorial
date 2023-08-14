#!/bin/bash

docker build \
  --build-arg USER_NAME=$USER \
  --build-arg USER_UID=$(id -u) \
  --build-arg VERSION=2023.1 \
  --build-arg INSTALLER_SUFFIX=05012318 \
  -f Dockerfile \
  -t kv260/petalinux-builder:0.3.0 \
  .
