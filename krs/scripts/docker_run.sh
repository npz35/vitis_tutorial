#!/bin/bash

USER_NAME=$USER

docker run --interactive --tty \
    --net host \
    --env DISPLAY=$DISPLAY \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume /tools/Xilinx:/tools/Xilinx:ro \
    --volume $HOME/output:/home/${USER_NAME}/output \
    --volume /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native \
    --env PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
    --user $(id -u) \
    --name krs \
    kv260/krs:0.2.2 \
    /bin/bash
