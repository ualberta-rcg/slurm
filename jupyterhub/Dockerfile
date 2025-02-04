FROM jupyterhub/k8s-hub:4.1.0

USER root

# Ensure UID and GID 999 for slurm before package installation
RUN groupadd -g 999 slurm && useradd -u 999 -g 999 -m -s /bin/bash slurm

# Ensure UID and GID 972 for Munge
RUN groupadd -g 972 munge && useradd -u 972 -g 972 -m -s /sbin/nologin munge \
    && groupadd -g 1000 wwgroup && useradd -m -u 1000 -g wwgroup wwuser

# Ensure jovyan can see the munge and slurm users
RUN usermod -aG munge,slurm jovyan

# Install minimal Slurm tools needed for job submission
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    git \
    ca-certificates \
    wget \
    gettext \
    pkg-config \
    fakeroot \
    devscripts \
    equivs \
    libpmix-dev \
    libpmix2 \
    libopenmpi-dev \
    libopenmpi3 \
    openmpi-bin \
    mailutils \
    munge \
    libmunge-dev \
    libmunge2 \
    iputils-ping \
    iproute2 \
    net-tools \
    curl \
    wget \
    vim \
    nano \
    less \
    htop \
    lsof \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/jupyterhub/ || true \
    && chmod 755 /etc/munge \ 
    && chmod a+r -R /etc/munge \
    && chmod a+w -R /etc/munge

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /usr/src && cd /usr/src && \
    curl -LO https://github.com/SchedMD/slurm/archive/refs/tags/slurm-${SLURM_VERSION}.tar.gz && \
    tar -xzf slurm-${SLURM_VERSION}.tar.gz && \
    cd slurm-slurm-${SLURM_VERSION} && \
    mk-build-deps -ir --tool='apt-get -qq -y -o Debug::pkgProblemResolver=yes' debian/control && \
    debuild -b -uc -us >/dev/null && \
    cd .. && \
    \
    # Define keywords to exclude (whitelist for exclusion)
    EXCLUDE_KEYWORDS=("slurmdbd" "slurmd" "slurmrestd" "slurmctld") && \
    \
    # Step 1: Generate the list of .deb files
    ALL_DEBS=($(find /usr/src/ -maxdepth 1 -type f -name "*.deb")) && \
    \
    # Step 2: Filter out unwanted .deb files
    INSTALL_LIST=() && \
    for deb in "${ALL_DEBS[@]}"; do \
        skip=false; \
        for keyword in "${EXCLUDE_KEYWORDS[@]}"; do \
            if [[ "$deb" == *"$keyword"* ]]; then \
                skip=true; \
                break; \
            fi; \
        done; \
        if [ "$skip" = false ]; then \
            INSTALL_LIST+=("$deb"); \
        fi; \
    done && \
    \
    # Step 3: Display the list of packages to be installed
    echo "The following .deb files will be installed:" && \
    printf '%s\n' "${INSTALL_LIST[@]}" && \
    \
    # Step 4: Install the selected .deb packages
    if [ "${#INSTALL_LIST[@]}" -gt 0 ]; then \
        apt-get install -y "${INSTALL_LIST[@]}"; \
    else \
        echo "No .deb packages to install."; \
    fi 

    
COPY batch_template.sh /etc/jupyterhub/
COPY form_template.html /etc/jupyterhub/

# Install BatchSpawner
RUN pip install batchspawner \
    && pip cache purge

# The jupyterhub user is the default user in jupyterhub/jupyterhub image
USER jupyterhub
