FROM ubuntu:18.04
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
        less \
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

ARG VERSION
ARG INSTALLER_SUFFIX

COPY --chown=${USER_NAME} petalinux-v${VERSION}-${INSTALLER_SUFFIX}-installer.run ${HOME}/petalinux-v${VERSION}-${INSTALLER_SUFFIX}-installer.run
RUN yes | ./petalinux-v${VERSION}-${INSTALLER_SUFFIX}-installer.run --skip_license && \
    rm ./petalinux-v${VERSION}-${INSTALLER_SUFFIX}-installer.run

RUN bash -c "echo 'source /tools/Xilinx/Vivado/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source /tools/Xilinx/Vitis_HLS/${VERSION}/settings64.sh' >> .bashrc" && \
    bash -c "echo 'source \${HOME}/settings.sh' >> .bashrc" && \
    bash -c "echo 'echo \"Please execute sudo /tools/Xilinx/Vitis/${VERSION}/scripts/installLibs.sh\"' >> .bashrc"
