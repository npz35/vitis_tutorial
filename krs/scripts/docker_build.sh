#!/bin/bash

docker build \
  --build-arg USER_NAME=$USER \
  --build-arg USER_UID=$(id -u) \
  -f Dockerfile \
  -t kv260/krs:1.0 \
  .
