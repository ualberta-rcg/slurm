#!/bin/bash

# Redirect logs to stdout and stderr for Kubernetes
if [ -z "${LOG_FILE}" ] || [ "${LOG_FILE}" = "/var/log/slurm/slurm-dbd.log" ]; then
  export LOG_FILE=/dev/stdout
fi

# Replace variables in the template and write to /etc/slurm/slurmdbd.conf
envsubst < /etc/slurm/slurmdbd.conf.template > /etc/slurm/slurmdbd.conf

# Run slurmdbd
exec slurmdbd "$@"
