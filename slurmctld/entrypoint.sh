#!/bin/bash

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurmctld.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Set proper permissions for slurm.conf
chown -R slurm:slurm /etc/slurm /var/spool/slurmctld /var/log/slurm/
chmod 644 /etc/slurm/slurm.conf

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
#while ! sacctmgr show cluster &>/dev/null; do
#    sleep 5
#    counter=$((counter + 2))
#    if [ $counter -ge $timeout ]; then
#        echo "Timeout waiting for slurmdbd to become available"
#        exit 1
#    fi
#    echo "Waiting for slurmdbd to become available..."
#done

# Run slurmctld in foreground mode
exec slurmctld "$@"
