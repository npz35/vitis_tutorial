FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt-get update -y -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-get install -y -qq --no-install-recommends \
        autoconf \
        bison \
        build-essential \
        chrpath \
        cmake \
        cpio \
        curl \
        diffstat \
        flex \
        g++ \
        gawk \
        gcc \
        gcc-multilib \
        git \
        gnupg \
        graphviz \
        libc6-dev-i386 \
        libglib2.0-dev \
        libncurses5-dev \
        libsdl1.2-dev \
        libselinux1 \
        libssl-dev \
        libtinfo5 \
        libtool \
        locales \
        lsb \
        make \
        net-tools \
        pax \
        pkg-config \
        screen \
        socat \
        software-properties-common \
        sudo \
        tar \
        texinfo \
        tofrodos \
        unzip \
        vim \
        wget \
        xterm \
        xvfb \
        zlib1g-dev \
        zlib1g-dev:i386 && \
    apt-get install -y -qq --no-install-recommends \
        tftpd-hpa && \
    rm -rf /var/lib/apt/lists/*

ARG USER_NAME
ARG USER_UID

RUN useradd --create-home \
        --uid ${USER_UID} \
        --shell /bin/bash \
        --groups sudo ${USER_NAME} && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER ${USER_NAME}
ENV HOME=/home/${USER_NAME}

WORKDIR ${HOME}

COPY --chown=${USER_NAME} petalinux-v2020.2-final-installer.run ${HOME}/petalinux-v2020.2-final-installer.run
RUN yes | ./petalinux-v2020.2-final-installer.run && \
    rm ./petalinux-v2020.2-final-installer.run

COPY --chown=${USER_NAME} system-user.dtsi ${HOME}/etc/template/project/common/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

RUN bash -c "echo 'export PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:\${PATH}' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vivado/2020.2/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis/2020.2/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis_HLS/2020.2/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source \${HOME}/settings.sh' >> .bashrc" && \
    bash -c "echo 'echo \"Please execute sudo /tools/Xilinx/Vitis/2020.2/scripts/installLibs.sh\"' >> .bashrc"
