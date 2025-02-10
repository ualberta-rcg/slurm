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

set -euo pipefail
echo "Starting JupyterHub on Slurm node"

# *** KEY CHANGE: Use batchspawner-singleuser correctly ***
${BATCHSPAWNER_SINGLEUSER_CMD} "${JUPYTERHUB_API_URL}" "${JUPYTERHUB_BASE_URL}" "${JUPYTERHUB_COOKIE_NAME}" "${JUPYTERHUB_USER}" "${JUPYTERHUB_API_TOKEN}" "${JUPYTERHUB_SERVER_NAME}"
