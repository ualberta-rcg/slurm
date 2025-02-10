#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output=/home/{username}/jupyterhub_%j.log
#SBATCH --error=/home/{username}/jupyterhub_%j.err
#SBATCH --time={runtime}
#SBATCH --nodes={nodes}
#SBATCH --ntasks={ntasks}
#SBATCH --qos={qos}
#SBATCH --partition={cluster}
#SBATCH --gres=gpu:{gpus}
#SBATCH --export=ALL
#SBATCH --constraint=""
#SBATCH --chdir=/home/{username}

set -euo pipefail
echo "Starting JupyterHub on Slurm node"

jupyter lab \
  --ip=0.0.0.0 \
  --port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()') \
  --NotebookApp.token="{JUPYTERHUB_API_TOKEN}" \
  --NotebookApp.base_url="{JUPYTERHUB_SERVICE_PREFIX}" \
  --no-browser
