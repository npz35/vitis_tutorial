#!/bin/bash

USER_NAME=$USER

docker run --interactive --tty --privileged \
    --env DISPLAY=$DISPLAY \
    --net host \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume /tools/Xilinx:/tools/Xilinx:ro \
    --volume $HOME/output:/home/${USER_NAME}/output \
    --volume $HOME/vitis_tutorial/petalinux:/home/${USER_NAME}/petalinux \
    --name build_petalinux \
    kv260/petalinux-builder:20.04 \
    /bin/bash
