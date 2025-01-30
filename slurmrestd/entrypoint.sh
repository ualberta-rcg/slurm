#!/bin/bash
export SLURM_JWT=daemon
export SLURMRESTD_DEBUG=debug

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurmrestd.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Set proper permissions for slurm directories
mkdir -p /var/spool/slurmrestd /var/log/slurm/ /var/run/slurm /etc/slurm
touch /var/log/slurm/slurmrestd.log
chown -R slurm:slurm /var/spool/slurmrestd /var/log/slurm/ /var/run/slurm /etc/slurm
chmod 644 /etc/slurm/*.conf

# Setup Munge
cp /etc/munge/.secret/munge.keyfile /etc/munge/munge.key
chown munge:munge -R /etc/munge
chmod 400 /etc/munge/munge.key

# Start munged in the background
su -s /bin/bash -c "/usr/sbin/munged --foreground --log-file=/var/log/munge/munge.log &" munge

# Wait briefly for munge to start
sleep 2

# Run slurmctld as the slurm user
exec su -s /bin/bash slurm -c "/usr/sbin/slurmrestd $*"
