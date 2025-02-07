#!/bin/bash

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurmctld.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Ensure the Slurm JWT key exists
JWT_KEY_PATH="/var/spool/slurmctld/jwt_hs256.key"

if [ ! -f "$JWT_KEY_PATH" ]; then
    echo "Creating JWT key for Slurm..."
    openssl rand -hex 32 > "$JWT_KEY_PATH"
fi

# Set proper permissions for slurm.conf
mkdir -p /var/spool/slurmctld /var/spool/slurmd /var/spool/slurmdbd /var/spool/slurmrestd /var/log/slurm/ /var/run/slurm /etc/slurm /run/munge 
touch /var/log/slurm/slurm-dbd.log /var/log/slurm/slurmctld.log /var/spool/slurmctld/priority_last_decay_ran
chown -R slurm:slurm /var/spool/slurmctld /var/spool/slurmd /var/spool/slurmdbd /var/spool/slurmrestd /var/log/slurm/ /var/run/slurm /etc/slurm
chmod 755 /var/spool/slurmctld
chmod 644 /etc/slurm/*.conf
chmod 660 "$JWT_KEY_PATH"
chown -R munge:munge /run/munge

# Setup Munge
cp /etc/munge/.secret/munge.keyfile /etc/munge/munge.key
chown munge:munge -R /etc/munge
chmod 400 /etc/munge/munge.key

# Start munged in the background
su -s /bin/bash -c "/usr/sbin/munged --foreground --log-file=/var/log/munge/munge.log &" munge

# Start sssd in the background
su -s /bin/bash -c "/usr/sbin/sssd -i -d 9 &" root

# Wait briefly for munge to start
sleep 2

# Create hosts-original 
cp /etc/hosts /etc/hosts-original
cat /etc/hosts.d/hosts >> /etc/hosts

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
    "/etc/hosts.d/hosts"
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
                    echo "Change detected in $file."

                    # Special handling for /etc/hosts.d/warewulf
                    if [[ "$file" == "/etc/hosts.d/warewulf" ]]; then
                        echo "Updating /etc/hosts with contents from /etc/hosts.d/warewulf..."
                        if [[ -f /etc/hosts-original ]]; then
                            cat /etc/hosts-original > /etc/hosts  # Start with the original hosts file
                            cat /etc/hosts.d/hosts >> /etc/hosts  # Append warewulf contents
                            echo "/etc/hosts updated successfully."
                        else
                            echo "Error: /etc/hosts-original does not exist!"
                        fi
                    else
                        echo "Reloading SLURM configuration due to change in $file..."
                        su -s /bin/bash slurm -c "/usr/bin/scontrol reconfigure"
                    fi

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
exec su -s /bin/bash slurm -c "/usr/sbin/slurmctld $*"
