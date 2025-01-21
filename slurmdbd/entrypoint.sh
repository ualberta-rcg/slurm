#!/bin/bash

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurm-dbd.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Read and substitute the template
while IFS= read -r line; do
  eval "echo \"$line\""
done < /etc/slurm/slurmdbd.conf.template > /etc/slurm/slurmdbd.conf

# Slurm 
#chown slurm:slurm /etc/slurm/slurmdbd.conf
#chown slurm:slurm -R /var/log/slurm
chmod 600 /etc/slurm/slurmdbd.conf

# Munge

chown munge:munge -R /etc/munge

su -s /bin/bash -c "/opt/software/munge/sbin/munged --foreground --log-file=/var/log/munge/munge.log  &" munge

# Run slurmdbd
exec slurmdbd "$@"

