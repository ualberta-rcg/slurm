# Base image
FROM debian:bullseye-slim

# Set environment variables
ENV SLURM_VERSION=24-05-5-1
ENV PREFIX=/opt/software/slurm
ENV PATH=/usr/local/ssl/bin:$PREFIX/bin:/opt/software/slurm/sbin:${PATH:-}
ENV LD_LIBRARY_PATH=/usr/local/ssl/lib:${LD_LIBRARY_PATH:-}

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    git \
    ca-certificates \
    libhwloc15 \
    libtool \
    libssl-dev \
    zlib1g-dev \
    liblua5.3-0 \
    libnuma1 \
    libpam0g \
    librrd8 \
    libyaml-0-2 \
    libjson-c5 \
    libhttp-parser2.9 \
    libev4 \
    libssl1.1 \
    libcurl4 \
    libbpf0 \
    libdbus-1-3 \
    libfreeipmi17 \
    libibumad3 \
    libibmad5 \
    libev-dev \
    libevent-dev \
    wget \
    gettext \
    linux-headers-amd64 \
    pkg-config \
    autoconf \
    automake \
    gcc \
    make \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    munge \
    libmunge-dev \
    libmunge2 \
    libpmix-dev \
    pmix \
    libopenmpi-dev \
    rrdtool \
    librrd-dev \
    libhdf5-dev \
    libmariadb-dev \
    libjson-c-dev \
    libhwloc-dev \
    libnuma-dev \
    libssl-dev \
    libyaml-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    gettext \
    lua5.3 \
    liblua5.3-dev && \
    ln -sf /usr/bin/python3 /usr/local/bin/python3 && \
    ln -sf /usr/bin/pip3 /usr/local/bin/pip3 && \
    mkdir -p /var/run/munge /run/munge /var/lib/munge /var/log/munge /etc/munge && \
    chown -R munge:munge /etc/munge /var/run/munge /var/lib/munge /var/log/munge /run/munge && \
    chmod 700 /var/lib/munge /var/run/munge && \
    chmod 755 /run/munge
 
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    build-essential \
#    cmake \
#    curl \
#    git \
#    ca-certificates \
#    libhwloc-dev \
#    liblua5.3-dev \
#    libnuma-dev \
#    libpam0g-dev \
#    libpmix-dev \
#    libreadline-dev \
#    rrdtool \
#    libyaml-dev \
#    libjson-c-dev \
#    libhttp-parser-dev \
#    libev-dev \
#    libev4 \
#    man-db \
#    wget \
#    gcc \
#    make \
#    gettext \
#    linux-headers-amd64 \
#    pkg-config \
#    autoconf \
#    automake \
#    libssl-dev \
#    libtool   \
#    libhdf5-dev \
#    libmariadb-dev \
#    libjwt-dev \
#    libreadline-dev \
#    libhttp-parser-dev \
#    libjson-c-dev \
#    libyaml-dev \
#    libgtk2.0-dev \
#    libcurl4-openssl-dev \
#    libbpf-dev \
#    libdbus-1-dev \
#    libibumad-dev \
#    libfreeipmi17 \
#    libibmad-dev
  
# Add runtime configurations, users and groups for Munge, Slurm, & Warewulf
RUN groupadd -r slurm && useradd -r -g slurm -s /bin/false slurm && \
    groupadd -r munge && useradd -r -g munge -s /bin/false munge && \
    groupadd -g 1000 wwgroup && useradd -m -u 1000 -g wwgroup wwuser

# Configure and build Slurm with the additional features enabled
RUN mkdir -p /usr/src && cd /usr/src && \
    curl -LO https://github.com/SchedMD/slurm/archive/refs/tags/slurm-${SLURM_VERSION}.tar.gz && \
    tar -xzf slurm-${SLURM_VERSION}.tar.gz && cd slurm-slurm-${SLURM_VERSION} && \
    ./configure --prefix=$PREFIX \
                --sysconfdir=/etc/slurm \
                --with-munge=/etc/munge \
                --with-pmix=/usr \
                --with-hdf5 \
                --with-mysql \
                --enable-debug \
                --enable-pam \
                --enable-restd \
                --enable-lua \
                --enable-rrdtool \
                --enable-mpi && \
    make -j$(nproc) && make install && \
    cd contribs && make && make install && \
    touch /var/log/slurm/slurm-dbd.log && \
    touch /var/log/slurm/slurmctld.log

COPY entrypoint.sh /entrypoint.sh

# Clean Up
RUN chmod +x /entrypoint.sh && \
    apt-get purge -y \
    build-essential \
    cmake \
    git \
    gcc \
    curl \
    wget \
    make \
    man-db \    
    zlib1g-dev \
    linux-headers-amd64 \
    pkg-config \
    autoconf \
    automake \
    libssl-dev \
    libev-dev \
    libevent-dev \
    libtool && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /usr/src/* /var/lib/apt/lists/* /tmp/* \
    /var/tmp/* /var/log/* /usr/share/doc /usr/share/man \
    /usr/share/locale /usr/share/info && \
    mkdir -p /etc/hosts.d/ && touch /etc/hosts.d/warewulf

# Expose required ports
EXPOSE 6817

# Entry point
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["-D", "-R", "-vvv", "-i", "-s"]
