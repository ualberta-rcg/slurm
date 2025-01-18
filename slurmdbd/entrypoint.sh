#!/bin/bash

# Export default values if not already set
#export AUTH_TYPE=${AUTH_TYPE:-auth/munge}
#export DBD_HOST=${DBD_HOST:-localhost}
#export DBD_PORT=${DBD_PORT:-6819}
#export STORAGE_TYPE=${STORAGE_TYPE:-accounting_storage/mysql}
#export STORAGE_HOST=${STORAGE_HOST:-localhost}
#export STORAGE_PORT=${STORAGE_PORT:-3306}
#export STORAGE_USER=${STORAGE_USER:-slurm}
#export STORAGE_PASS=${STORAGE_PASS:-password}
#export STORAGE_LOC=${STORAGE_LOC:-slurm_acct_db}
#export LOG_FILE=${LOG_FILE:-/var/log/slurm/slurmdbd.log}
#export PID_FILE=${PID_FILE:-/var/run/slurmdbd.pid}
#export SLURM_USER=${SLURM_USER:-slurm}
#export DEBUG_LEVEL=${DEBUG_LEVEL:-debug}

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurm-dbd.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Read and substitute the template
while IFS= read -r line; do
  eval "echo \"$line\""
done < /etc/slurm/slurmdbd.conf.template > /etc/slurm/slurmdbd.conf


# Slurm 
mkdir -p /var/log/slurm/
touch /var/log/slurm/slurm-dbd.log
chown slurm:slurm /etc/slurm/slurmdbd.conf
chown slurm:slurm -R /var/log/slurm
chmod 600 /etc/slurm/slurmdbd.conf

# Munge
mkdir -p /var/run/munge/
mkdir -p /var/lib/munge/
chmod 400 /etc/munge/munge/munge.key
chmod 700 /var/lib/munge
chmod 700 /var/run/munge/
chmod 750 -R /etc/munge
chown munge:munge -R /etc/munge
chown munge:munge -R /var/run/munge
chown munge:munge -R /var/lib/munge

su -s /bin/bash -c "/opt/software/munge/sbin/munged --foreground -f &" munge

# Run slurmdbd
exec slurmdbd "$@"
