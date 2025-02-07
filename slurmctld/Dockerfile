# Base image
FROM debian:bullseye-slim

# Pre-configure LDAP packages to avoid interactive prompts
RUN echo "nslcd nslcd/ldap-uris string ldap://localhost" | debconf-set-selections && \
    echo "nslcd nslcd/ldap-base string dc=example,dc=com" | debconf-set-selections && \
    echo "libnss-ldapd libnss-ldapd/nsswitch multiselect passwd, group, shadow" | debconf-set-selections && \
    echo "libpam-ldapd libpam-ldapd/enable-debug boolean false" | debconf-set-selections

# Add runtime configurations, users and groups for Munge, Slurm, & Warewulf
RUN groupadd -g 999 -r slurm && useradd -r -g slurm -u 999 -s /bin/false slurm && \
    groupadd -g 1000 wwgroup && useradd -m -u 1000 -g wwgroup wwuser

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libpmix-dev \
    libpmix2 \
    libopenmpi-dev \
    libopenmpi3 \
    openmpi-bin \
    mailutils \
    munge \
    sssd \
    sssd-tools \
    libnss-sss \
    libpam-sss \
    libsss-sudo \
    ldap-utils \
    libldap-common \
    libnss-ldapd \
    libpam-ldapd

SHELL ["/bin/bash", "-c"]

RUN EXCLUDE_KEYWORDS=("slurmdbd" "slurmd" "slurmrestd") && \
    ALL_DEBS=($(find / -maxdepth 1 -type f -name "*.deb")) && \
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

COPY entrypoint.sh /entrypoint.sh

# Clean Up
RUN chmod +x /entrypoint.sh && \
    apt-get purge -y \
    man-db && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm /*.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/* \
    /var/tmp/* /var/log/* /usr/share/doc /usr/share/man \
    /usr/share/locale /usr/share/info && \
    mkdir -p /etc/hosts.d/ && touch /etc/hosts.d/hosts && \
    sed -i -E 's/^(passwd:\s*)files/\1slurm files/; s/^(group:\s*)files/\1slurm files/; s/^(hosts:\s*files)/\1 slurm/' /etc/nsswitch.conf

# Expose required ports
EXPOSE 6817

# Entry point
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["-D", "-R", "-vvv", "-i", "-s"]
