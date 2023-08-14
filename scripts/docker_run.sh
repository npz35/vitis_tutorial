#!/bin/bash

USER_NAME=$USER

if [ ! -d ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx} ]; then
    echo "${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx} does not existed." >&2
    exit 1
fi

docker run --interactive --tty --privileged \
    --env DISPLAY=$DISPLAY \
    --net host \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:/tools/Xilinx:ro \
    --volume ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:ro \
    --volume $HOME/krs_workdir_2023_1:/home/${USER_NAME}/krs_workdir_2023_1 \
    --name build_petalinux \
    kv260/petalinux-builder:0.3.0 \
    /bin/bash
