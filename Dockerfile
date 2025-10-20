FROM ubuntu:latest

ARG USER=user
ARG VERILATOR_VERSION=v5.040

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Setup base system (we install weston to easily get all the Wayland deps)
RUN apt-get -y update && \
    apt-get install -y sudo weston mesa-vulkan-drivers openssh-client git iputils-ping vulkan-tools curl

# Trunk.io simplifies automated code quality control
RUN curl https://get.trunk.io -fsSL | bash

# Setup non-root user since some things don't like running as root
RUN usermod -l ${USER} ubuntu -m -d /home/${USER} && \
    echo passwd -d ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/$USER

# Setup tools installed into the home dir
COPY prep-home.sh /prep-home.sh
RUN chmod +x /prep-home.sh && chown ${USER} /prep-home.sh
USER ${USER}
RUN /prep-home.sh

# Install dependencies (mostly for verilator)
RUN sudo apt-get install -y \
    help2man perl python3 make autoconf g++ flex bison ccache gdb \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev pkg-config libssl-dev libclang-dev \
    zlib1g zlib1g-dev \
    clang clang-format \
    gtkwave cmake ninja-build \
    libspdlog-dev

# Clone and build Verilator from source as to have the latest version
RUN git clone https://github.com/verilator/verilator.git /home/${USER}/verilator && \
    cd /home/${USER}/verilator && \
    git checkout ${VERILATOR_VERSION} && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    sudo make install && \
    rm -rf /home/${USER}/verilator
