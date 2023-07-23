#!/bin/bash

USER_NAME=$USER

docker run --interactive --tty --privileged \
    --env DISPLAY=$DISPLAY \
    --net host \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume /tools/Xilinx:/tools/Xilinx:ro \
    --volume $HOME/krs_workdir_2023_1:/home/${USER_NAME}/krs_workdir_2023_1 \
    --name build_petalinux \
    kv260/petalinux-builder:0.2.2 \
    /bin/bash
