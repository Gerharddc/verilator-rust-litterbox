FROM ubuntu:latest

ARG VERILATOR_VERSION=v5.040

# Setup base system (we install weston to easily get all the Wayland deps)
RUN apt-get update && \
    apt-get install -y sudo weston mesa-vulkan-drivers openssh-client git iputils-ping vulkan-tools

# Install dependencies (mostly for verilator)
RUN apt-get -y update && apt-get install -y \
    help2man perl python3 make autoconf g++ flex bison ccache gdb \
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev pkg-config libssl-dev libclang-dev \
    zlib1g zlib1g-dev \
    curl clang clang-format \
    gtkwave cmake ninja-build \
    libspdlog-dev

# Clone and build Verilator from source as to have the latest version
RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    git checkout ${VERILATOR_VERSION} && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/verilator

COPY prep-home.sh prep-home.sh
RUN ./prep-home.sh
