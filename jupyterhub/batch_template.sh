#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output=/home/${username}/jupyterhub_%j.log
#SBATCH --error=/home/${username}/jupyterhub_%j.err
#SBATCH --partition=${cluster}
#SBATCH --qos=${qos}
#SBATCH --nodes=${nodes}
#SBATCH --ntasks-per-node=${ntasks}
#SBATCH --time=${runtime}
#SBATCH --gres=gpu:${gpus}
#SBATCH --chdir=/home/${username}

# Load necessary modules
module load python/3.8

# Get the hostname of the compute node
HOSTNAME=$(hostname)
PORT=8888

# Start JupyterLab on the compute node
jupyter-lab --no-browser --port=$PORT --ip=0.0.0.0 --allow-root &

# Sleep to ensure JupyterLab starts
sleep 5

# Write connection info to a known file location
echo "JUPYTERHUB_REMOTE_HOST=$HOSTNAME" >> /tmp/jupyterhub-${SLURM_JOB_ID}.log
echo "JUPYTERHUB_REMOTE_PORT=$PORT" >> /tmp/jupyterhub-${SLURM_JOB_ID}.log
