FROM ros:humble-ros-core
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-get install -y -qq --no-install-recommends \
        build-essential \
        cpio \
        curl \
        fdisk \
        g++ \
        gdisk \ 
        git \
        graphviz \
        kpartx \
        libeigen3-dev \
        libboost-dev \
        libc6-dev-i386 \
        libncursesw5 \
        libopencv-dev \
        libssl-dev \
        locales \
        libtinfo5 \
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
        ros-humble-camera-info-manager \
        ros-humble-cv-bridge \
        ros-humble-gazebo-ros \
        ros-humble-image-geometry \
        ros-humble-image-transport \
        ros-humble-rqt-graph \
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

# Please refer to https://xilinx.github.io/KRS/sphinx/build/html/docs/install.html
COPY --chown=${USER_NAME} krs_humble.repos ${HOME}/krs_humble.repos
RUN mkdir -p ${HOME}/krs_ws/src && \
    mv krs_humble.repos ${HOME}/krs_ws/ && \
    cd ${HOME}/krs_ws && \
    vcs import src --recursive < krs_humble.repos && \
    . /opt/ros/humble/setup.sh && \
    colcon build \
        --merge-install \
        --packages-ignore \
            acceleration_firmware_kv260 \
            perception_3nodes

RUN bash -c "echo 'source /tools/Xilinx/Vivado/2022.1/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis/2022.1/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis_HLS/2022.1/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /opt/ros/humble/setup.bash' >> .bashrc" && \
    bash -c "echo 'export PATH="/usr/bin:\$PATH"' >> .bashrc"
