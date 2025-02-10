#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output=/home/${username}/jupyterhub_%j.log
#SBATCH --error=/home/${username}/jupyterhub_%j.err
#SBATCH --time=${runtime}
#SBATCH --nodes=${nodes}
#SBATCH --ntasks=${ntasks}
#SBATCH --qos=${qos}
#SBATCH --partition=${cluster}
#SBATCH --gres=gpu:${gpus}
#SBATCH --export=ALL
#SBATCH --constraint=""
#SBATCH --chdir=/home/${username}

echo "Starting JupyterHub on Slurm node"

# Get the hostname of the allocated node
export JUPYTERHUB_REMOTE_HOST=$(hostname)
export JUPYTERHUB_REMOTE_PORT=${port}

echo "JUPYTERHUB_REMOTE_HOST=${JUPYTERHUB_REMOTE_HOST}" >> /tmp/jupyterhub-${SLURM_JOB_ID}.log
echo "JUPYTERHUB_REMOTE_PORT=${JUPYTERHUB_REMOTE_PORT}" >> /tmp/jupyterhub-${SLURM_JOB_ID}.log

# Start Jupyter
jupyterhub-singleuser --ip=0.0.0.0 --port=${port} --NotebookApp.token='' --NotebookApp.password=''
