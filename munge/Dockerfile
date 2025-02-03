FROM archlinux:base

# Install munge and clean up
RUN pacman -Sy --noconfirm munge && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Create munge key directory and set permissions
RUN mkdir -p /etc/munge && \
    chown munge:munge /etc/munge && \
    chmod 700 /etc/munge

# Create munge socket directory
RUN mkdir -p /var/run/munge && \
    chown munge:munge /var/run/munge && \
    chmod 755 /var/run/munge

# Create log directory
RUN mkdir -p /var/log/munge && \
    chown munge:munge /var/log/munge && \
    chmod 700 /var/log/munge

# Switch to munge user
USER munge

# Command to start munge daemon
CMD ["munged", "--foreground"]
