#!/bin/bash

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurmctld.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Set proper permissions for slurm.conf
mkdir -p /var/spool/slurmctld /var/log/slurm/ 
chown -R slurm:slurm /etc/slurm /var/spool/slurmctld /var/log/slurm /opt/software/slurm/sbin
chmod 644 /etc/slurm/*.conf

# Setup Munge
cp /etc/munge/.secret/munge.keyfile /etc/munge/munge.key
chown munge:munge -R /etc/munge
chmod 400 /etc/munge/munge.key

# Start munged in the background
su -s /bin/bash -c "/opt/software/munge/sbin/munged --foreground --log-file=/var/log/munge/munge.log &" munge

# Wait briefly for munge to start
sleep 2

# Verify that the slurmdbd is accessible before starting slurmctld
timeout=60
counter=0
while ! sacctmgr show cluster &>/dev/null; do
    sleep 5
    counter=$((counter + 2))
    if [ $counter -ge $timeout ]; then
        echo "Timeout waiting for slurmdbd to become available"
        exit 1
    fi
    echo "Waiting for slurmdbd to become available..."
done

# Start monitoring Slurm configuration files for changes
CONFIG_FILES=(
    "/etc/slurm/slurm.conf"
    "/etc/slurm/gres.conf"
    "/etc/slurm/cgroup.conf"
)

# Function to monitor configuration files
monitor_config_files() {
    declare -A FILE_CHECKSUMS

    # Initialize checksums
    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f $file ]]; then
            FILE_CHECKSUMS["$file"]=$(md5sum "$file" | awk '{print $1}')
        else
            FILE_CHECKSUMS["$file"]=""
        fi
    done

    echo "Monitoring configuration files for changes..."

    while true; do
        for file in "${CONFIG_FILES[@]}"; do
            if [[ -f $file ]]; then
                NEW_CHECKSUM=$(md5sum "$file" | awk '{print $1}')
                if [[ "${FILE_CHECKSUMS["$file"]}" != "$NEW_CHECKSUM" ]]; then
                    echo "Change detected in $file. Reloading SLURM configuration..."
                    su -s /bin/bash slurm -c "/opt/software/slurm/sbin/scontrol reconfigure"
                    FILE_CHECKSUMS["$file"]="$NEW_CHECKSUM"
                fi
            fi
        done
        sleep 5  # Adjust the interval as needed
    done
}

# Start monitoring in the background
(monitor_config_files) &

# Run slurmctld as the slurm user
exec su -s /bin/bash slurm -c "/opt/software/slurm/sbin/slurmctld $*"
