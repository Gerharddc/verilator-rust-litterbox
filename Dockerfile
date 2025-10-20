FROM ubuntu:latest

ARG VERILATOR_VERSION=v5.040

ARG USER=user
ARG HOSTNAME=lbx-ubuntu

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
    libspdlog-dev \
    zsh

# Clone and build Verilator from source as to have the latest version
RUN git clone https://github.com/verilator/verilator.git /tmp/verilator && \
    cd /tmp/verilator && \
    git checkout ${VERILATOR_VERSION} && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/verilator

# Setup non-root user with a password for added security
RUN usermod -l $USER ubuntu -m -d /home/$USER && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    echo "${USER} ALL=(ALL) ALL" >> /etc/sudoers && \
    echo 127.0.0.1 "${HOSTNAME}" >> /etc/hosts
WORKDIR /home/$USER

# Setup tools installed into the home dir
COPY prep-home.sh /prep-home.sh
RUN chmod +x /prep-home.sh && chown $USER /prep-home.sh
USER $USER
RUN /prep-home.sh

# Install Oh My Zsh for convenience
RUN chsh -s $(which zsh)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Set the default shell to Zsh
CMD ["zsh"]
