FROM ubuntu:latest

ARG USER=user
ARG VERILATOR_VERSION=v5.040

# Setup non-root user with a password for added security
RUN usermod -l ${USER} ubuntu -m -d /home/${USER} && \
    echo passwd -d ${USER} && \
    echo "${USER} ALL=(ALL) ALL" >> /etc/sudoers
WORKDIR /home/$USER

# Setup tools installed into the home dir
COPY prep-home.sh /prep-home.sh
RUN chmod +x /prep-home.sh && chown ${USER} /prep-home.sh
USER ${USER}
RUN /prep-home.sh

# Setup base system (we install weston to easily get all the Wayland deps)
RUN sudo apt-get -y update && \
    sudo apt-get install -y sudo weston mesa-vulkan-drivers openssh-client git iputils-ping vulkan-tools

# Install dependencies (mostly for verilator)
RUN sudo apt-get install -y \
    help2man perl python3 make autoconf g++ flex bison ccache gdb \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev pkg-config libssl-dev libclang-dev \
    zlib1g zlib1g-dev \
    curl clang clang-format \
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
