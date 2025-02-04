FROM archlinux:base

# Install munge, networking/system tools, sudo, and clean up
RUN pacman -Sy --noconfirm \
    munge \
    iputils \
    inetutils \
    iproute2 \
    net-tools \
    curl \
    wget \
    vim \
    nano \
    less \
    lsof \
    && pacman -Scc --noconfirm \
    && rm -rf /var/cache/pacman/pkg/*

# Create Munge directories & set correct permissions
RUN mkdir -p /etc/munge /var/run/munge /var/log/munge \
    && chown -R munge:munge /etc/munge /var/run/munge /var/log/munge \
    && chmod 750 /etc/munge \
    && chmod 770 /var/run/munge \
    && chmod 755 /var/log/munge

# Create log directory
RUN mkdir -p /var/log/munge && \
    chown munge:munge /var/log/munge 

# Switch to munge user
USER munge

# Command to start munge daemon
CMD ["munged", "--foreground", "--force", "--verbose", "--syslog"]
