FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt install -y \
    libc6:i386 \
    libc6-dbg:i386 \
    libc6-dbg \
    lib32stdc++6 \
    g++-multilib \
    cmake \
    vim \
    net-tools \
    iputils-ping \
    libffi-dev \
    libssl-dev \
    build-essential \
    ruby \
    ruby-dev \
    tmux \
    strace \
    ltrace \
    nasm \
    wget \
    gdb \
    gdb-multiarch \
    socat \
    git \
    patchelf \
    gawk \
    file \
    bison \
    rpm2cpio cpio \
    zstd \
    zsh \
    tzdata --fix-missing && \
    rm -rf /var/lib/apt/lists/*

#    python3-distutils \
    # python3-pip \
    # ipython3 \
    # python3-dev \


RUN git clone --depth 1 https://github.com/radareorg/radare2 && cd radare2 && sys/install.sh

RUN gem install elftools one_gadget seccomp-tools && rm -rf /var/lib/gems/*/cache/*

RUN git clone --depth 1 https://github.com/pwndbg/pwndbg && \
    cd pwndbg && chmod +x setup.sh && ./setup.sh

RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb && \
    echo "source ~/Pwngdb/.gdbinit-pwngdb" >> ~/.gdbinit

RUN wget -O ~/.gdbinit-gef.py -q http://gef.blah.cat/py


# Customization
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
RUN echo 'eval "$(starship init bash)"' >> /root/.bashrc

# Create User
# User setup with sudo
ENV USER=hacker
RUN useradd -m -s /bin/bash ${USER} && \
    usermod -aG sudo ${USER}

RUN mkdir /etc/sudoers.d/ && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-${USER} \
    && chmod 440 /etc/sudoers.d/90-${USER}
USER ${USER}
WORKDIR /home/${USER}

# Python uv setup
RUN curl -LsSf https://astral.sh/uv/install.sh | sh 
ENV PATH="/home/${USER}/.local/bin:${PATH}"

# pwntools currently doesn't work on 3.13
RUN uv venv --python 3.12
RUN uv pip install --no-cache \
    ipython \
    ropgadget \
    z3-solver \
    smmap2 \
    apscheduler \
    ropper \
    unicorn \
    keystone-engine \
    capstone \
    angr \
    pebble \
    pwntools \
    r2pipe

### Quality of life ###
ENV TERM=xterm-256color
RUN git clone --depth 1 https://github.com/junegunn/fzf.git .fzf
RUN .fzf/install

RUN echo 'eval "$(starship init bash)"' >> .bashrc
RUN echo 'source /home/hacker/.venv/bin/activate' >> .bashrc

CMD [ "/bin/bash" ]