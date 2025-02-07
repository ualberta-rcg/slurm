FROM jupyterhub/k8s-hub:4.1.0

USER root

ENV SLURM_VERSION=24-05-5-1

# Ensure UID and GID 999 for slurm before package installation
RUN groupadd -g 999 slurm && useradd -u 999 -g 999 -m -s /bin/bash slurm

# Ensure UID and GID 972 for Munge
RUN groupadd -g 972 munge && useradd -u 972 -g 972 -m -s /sbin/nologin munge 

# Ensure jovyan can see the munge and slurm users
RUN usermod -aG munge,slurm jovyan

# Install minimal Slurm tools needed for job submission
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    wget \
    gettext \
    libpmix-dev \
    libpmix2 \
    libopenmpi-dev \
    libopenmpi3 \
    openmpi-bin \
    mailutils \
    sudo \
    munge \
    libmunge-dev \
    libmunge2 \  
    sssd \
    sssd-tools \
    libnss-sss \
    libpam-sss \
    libsss-sudo \
    ldap-utils \
    libldap-common \
    libnss-ldapd \
    libpam-ldapd \
    curl \
    wget \
    vim \
    nano \
    less \
    htop \
    lsof \
    && mkdir -p /etc/jupyterhub/ || true \
    && chmod 755 /etc/munge \ 
    && chmod a+r -R /etc/munge \
    && chmod a+w -R /etc/munge

SHELL ["/bin/bash", "-c"]

# Copy all .deb files into the container
COPY *debian12.deb /tmp/

COPY batch_template.sh /etc/jupyterhub/
COPY form_template.html /etc/jupyterhub/

RUN cd /tmp && \
    EXCLUDE_KEYWORDS=("slurmdbd" "slurmd" "slurmrestd" "slurmctld") && \
    ALL_DEBS=($(find ./ -maxdepth 1 -type f -name "*.deb")) && \
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
    echo "The following .deb files will be installed:" && \
    printf '%s\n' "${INSTALL_LIST[@]}" && \
    if [ "${#INSTALL_LIST[@]}" -gt 0 ]; then \
        apt-get install -y "${INSTALL_LIST[@]}"; \
    else \
        echo "No .deb packages to install."; \
    fi 

# Install BatchSpawner
RUN pip install batchspawner \
    && pip cache purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Allow 'jovyan' and users in 'docker' group to use sudo without password
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/jovyan \
    && echo "%docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/docker \
    && chmod 0440 /etc/sudoers.d/jovyan /etc/sudoers.d/docker \
    && echo "Defaults !requiretty" >> /etc/sudoers

USER jovyan
