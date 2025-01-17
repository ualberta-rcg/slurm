#!/bin/bash

# Replace variables in the template and write to /etc/slurm/slurmdbd.conf
envsubst < /etc/slurm/slurmdbd.conf.template > /etc/slurm/slurmdbd.conf

# Run slurmdbd
exec slurmdbd "$@"
