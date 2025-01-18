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
mkdir -p /var/log/slurm/
touch /var/log/slurm/slurm-dbd.log
chown slurm:slurm /etc/slurm/slurmdbd.conf
chown slurm:slurm -R /var/log/slurm
chmod 600 /etc/slurm/slurmdbd.conf

# Munge
mkdir -p /var/run/munge/
mkdir -p /var/lib/munge/
mkdir -p /var/log/munge/
cp /etc/munge/munge/munge.key /etc/munge/
chmod 400 /etc/munge/munge.key
chmod 700 /var/lib/munge
chmod 700 /var/run/munge/
chmod 750 -R /etc/munge
chown munge:munge -R /etc/munge
chown munge:munge -R /var/run/munge
chown munge:munge -R /var/lib/munge
chown munge:munge -R /var/log/munge
chown munge:munge -R /run/munge
chmod 755 /run/munge 

su -s /bin/bash -c "/opt/software/munge/sbin/munged --foreground --log-file=/var/log/munge/munge.log  &" munge

# Run slurmdbd
exec slurmdbd "$@"
