FROM ros:humble-ros-core
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-get install -y -qq --no-install-recommends \
        build-essential \
        cpio \
        curl \
        fdisk \
        file \
        g++ \
        g++-aarch64-linux-gnu \
        gcc-aarch64-linux-gnu \
        gdisk \ 
        git \
        graphviz \
        imagemagick \
        kpartx \
        libeigen3-dev \
        libboost-dev \
        libc6-dev-i386 \
        libncursesw5 \
        libopencv-dev \
        libssl-dev \
        locales \
        libtinfo5 \
        liblttng-ust-dev \
        lttng-modules-dkms \
        lttng-tools \
        make \
        net-tools \
        ocl-icd-* \
        opencl-headers \
        parted \
        pkg-config \
        pv \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-vcstool \
        python3-pip \
        ros-humble-camera-info-manager \
        ros-humble-cv-bridge \
        ros-humble-gazebo-ros \
        ros-humble-gazebo-ros-pkgs \
        ros-humble-image-geometry \
        ros-humble-image-transport \
        ros-humble-rqt-graph \
        ros-humble-rqt-image-view \
        ros-humble-tf2-eigen \
        ros-humble-tf2-geometry-msgs \
        ros-humble-tf2-ros \
        ros-humble-tracetools-acceleration \
        sudo \
        tar \
        unzip \
        u-boot-tools \
        vim \
        wget \
        xvfb && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

ARG USER_NAME
ARG USER_UID

RUN useradd --create-home \
        --uid ${USER_UID} \
        --shell /bin/bash \
        --groups sudo ${USER_NAME} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}

WORKDIR ${HOME}

RUN python3 -m pip install \
    pytk \
    tk-tools \
    wasabi \
    pandas \
    bokeh \
    plotly \
    kaleido

# Please refer to https://xilinx.github.io/KRS/sphinx/build/html/docs/install.html
COPY --chown=${USER_NAME} krs_humble.repos ${HOME}/krs_humble.repos
RUN mkdir -p ${HOME}/krs_ws/src && \
    mv krs_humble.repos ${HOME}/krs_ws/ && \
    cd ${HOME}/krs_ws && \
    vcs import src --recursive < krs_humble.repos

COPY --chown=${USER_NAME} images/linux/pmu_rom_qemu_sha3.elf ${HOME}/images/linux/pmu_rom_qemu_sha3.elf
COPY --chown=${USER_NAME} images/linux/sdk.sh                ${HOME}/images/linux/sdk.sh
COPY --chown=${USER_NAME} images/linux/system.bit            ${HOME}/images/linux/system.bit

RUN cd ${HOME}/krs_ws && \
    mkdir -p ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260 && \
    mv \
        src/firmware/acceleration_firmware_kv260/acceleration_firmware_kv260/firmware \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/ && \
    mkdir -p src/firmware/acceleration_firmware_kv260/acceleration_firmware_kv260/firmware/data && \
    mv ${HOME}/images/linux/* src/firmware/acceleration_firmware_kv260/acceleration_firmware_kv260/firmware/ && \
    cp -r \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/firmware/imagebuilder \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/firmware/lib \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/firmware/SOC \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/firmware/device_tree \
        ${HOME}/acceleration_firmware_kv260-v1.0.0/acceleration_firmware_kv260/firmware/shell.json \
        src/firmware/acceleration_firmware_kv260/acceleration_firmware_kv260/firmware/

RUN cd ${HOME}/krs_ws && \
    XSA_PATH="${HOME}/krs_workdir_2023_1/kv260_hardware_platform.xsa" && \
    CFG_PLATFORM_PATH=`echo $XSA_PATH | sed 's/\\//\\\\\\//g'` && \
    find src -name kv260.cfg | xargs sed -i "s/platform=kv260_custom_platform/platform=${CFG_PLATFORM_PATH}/g"

RUN cd ${HOME}/krs_ws && \
    . /opt/ros/humble/setup.sh && \
    colcon build \
        --merge-install \
        --packages-ignore \
            acceleration_firmware_kv260 \
            perception_3nodes \
            accelerated_doublevadd_publisher \
            doublevadd_publisher \
            faster_doublevadd_publisher \
            multiple_doublevadd_publisher \
            offloaded_doublevadd_publisher \
            accelerated_vadd

RUN cd ${HOME}/krs_ws && \
    . /opt/ros/humble/setup.sh && \
    colcon build \
        --merge-install \
        --packages-select acceleration_firmware_kv260

RUN cd ${HOME}/krs_ws && \
    mkdir -p acceleration/firmware/vitis && \
    ln -s /tools/Xilinx/Vitis/2023.1/gnu acceleration/firmware/vitis/gnu && \
    touch acceleration/firmware/vitis/COLCON_IGNORE

ARG VERSION
RUN bash -c "echo 'source /tools/Xilinx/Vivado/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis_HLS/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /opt/ros/humble/setup.bash' >> .bashrc" && \
    bash -c "echo 'export PATH="/usr/bin:\$PATH"' >> .bashrc"
