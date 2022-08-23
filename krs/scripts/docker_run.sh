#!/bin/bash

USER_NAME=$USER

docker run --interactive --tty \
    --env DISPLAY=$DISPLAY \
    --net host \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume /tools/Xilinx:/tools/Xilinx:ro \
    --volume $HOME/output:/home/${USER_NAME}/output \
    --name krs \
    kv260/krs:1.0 \
    /bin/bash
