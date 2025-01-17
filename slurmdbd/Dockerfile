# Base image
FROM debian:bullseye-slim

# Set environment variables
ENV SLURM_VERSION=24-05-5-1
ENV OPENSSL_VERSION=3.0.15
ENV PYTHON_VERSION=3.12.8
ENV MUNGE_VERSION=0.5.14
ENV PMIX_VERSION=5.0.6
ENV PREFIX=/opt/software/slurm
ENV MUNGE_PREFIX=/opt/software/munge
ENV PMIX_PREFIX=/opt/software/pmix
ENV HWLOC_PREFIX=/opt/software/hwloc
ENV PATH=/usr/local/ssl/bin:$PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/ssl/lib:$LD_LIBRARY_PATH

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    git \
    hwloc \
    ca-certificates \
    libhwloc-dev \
    liblua5.3-dev \
    mariadb-client \
    libmunge-dev \
    libnuma-dev \
    libpam0g-dev \
    libpmix-dev \
    libreadline-dev \
    rrdtool \
    libyaml-dev \
    libjson-c-dev \
    libhttp-parser-dev \
    man-db \
    wget \
    gcc \
    make \
    gettext \
    linux-headers-amd64 \
    pkg-config \
    autoconf \
    automake \
    libssl-dev \
    libtool && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Add users and groups for Munge and Slurm
RUN groupadd -r slurm && useradd -r -g slurm -s /bin/false slurm && \
    groupadd -r munge && useradd -r -g munge -s /bin/false munge

# Install OpenSSL from source
RUN mkdir -p /usr/src && cd /usr/src && \
    wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar -xvf openssl-${OPENSSL_VERSION}.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib && \
    make -j$(nproc) && make install

# Install Python from source
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xvf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && make altinstall && \
    ln -s /usr/local/bin/python3.10 /usr/local/bin/python3 && \
    ln -s /usr/local/bin/pip3.10 /usr/local/bin/pip3

# Build and install MUNGE
RUN mkdir -p /usr/src && cd /usr/src && \
    curl -LO https://github.com/dun/munge/archive/munge-${MUNGE_VERSION}.tar.gz && \
    tar -xzf munge-${MUNGE_VERSION}.tar.gz && \
    cd munge-munge-${MUNGE_VERSION} && \
    ./bootstrap && \
    ./configure --prefix=$MUNGE_PREFIX --sysconfdir=/etc/munge --localstatedir=/var && \
    make -j$(nproc) && make install && \
    mkdir -p /var/lib/munge /var/log/munge /etc/munge && \
    chown -R munge:munge /var/lib/munge /var/log/munge /etc/munge

# Build and install PMIx
RUN mkdir -p /usr/src && cd /usr/src && \
    curl -LO https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/pmix-${PMIX_VERSION}.tar.gz && \
    tar -xzf pmix-${PMIX_VERSION}.tar.gz && cd pmix-${PMIX_VERSION} && \
    ./configure --prefix=$PMIX_PREFIX && make -j$(nproc) && make install

# Install HWLOC from source (if needed for Slurm)
RUN mkdir -p /usr/src && cd /usr/src && \
    wget https://download.open-mpi.org/release/hwloc/v2.9/hwloc-2.9.0.tar.gz && \
    tar -xzf hwloc-2.9.0.tar.gz && \
    cd hwloc-2.9.0 && \
    ./configure --prefix=$HWLOC_PREFIX && make -j$(nproc) && make install


# Download and build Slurm
RUN mkdir -p /usr/src && cd /usr/src && \
    curl -LO https://github.com/SchedMD/slurm/archive/refs/tags/slurm-${SLURM_VERSION}.tar.gz && \
    tar -xzf slurm-${SLURM_VERSION}.tar.gz && cd slurm-slurm-${SLURM_VERSION} && \
    ./configure --prefix=$PREFIX \
                --sysconfdir=/etc/slurm \
                --with-munge=$MUNGE_PREFIX \
                --with-pmix=$PMIX_PREFIX \
                --enable-debug \
                --enable-pam \
                --enable-restd \
                --enable-lua && \
    make -j$(nproc) && make install

# Add runtime configurations
RUN mkdir -p /etc/slurm /var/spool/slurm /var/log/slurm && \
    chown slurm:slurm /etc/slurm /var/spool/slurm /var/log/slurm

# Expose required ports
EXPOSE 6817 6818 6819

# Entry point
CMD ["/bin/bash"]
