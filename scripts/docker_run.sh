#!/bin/bash

USER_NAME=$USER

# mkdir -p work
# --volume work:/home/${USER_NAME}/xilinx-kv260-starterkit-2022.1

docker run --interactive --tty --privileged \
    --env DISPLAY=$DISPLAY \
    --net host \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume /tools/Xilinx:/tools/Xilinx:ro \
    --volume $HOME/output:/home/${USER_NAME}/output \
    --name build_petalinux \
    kv260/petalinux-builder:20.04 \
    /bin/bash
