#!/bin/bash

USER_NAME=$USER

if [ ! -d ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx} ]; then
    echo "${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx} does not existed." >&2
    exit 1
fi

docker run --interactive --tty \
    --net host \
    --env DISPLAY=$DISPLAY \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --volume $HOME/.Xauthority:/home/${USER_NAME}/.Xauthority \
    --volume ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:/tools/Xilinx:ro \
    --volume ${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:${XILINX_TOOLS_INSTALL_DIR_PREFIX:-/tools/Xilinx}:ro \
    --volume $HOME/krs_workdir_2023_1:/home/${USER_NAME}/krs_workdir_2023_1 \
    --volume /run/user/$(id -u)/pulse/native:/run/user/$(id -u)/pulse/native \
    --env PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
    --user $(id -u) \
    --name krs \
    kv260/krs:0.4.0 \
    /bin/bash
