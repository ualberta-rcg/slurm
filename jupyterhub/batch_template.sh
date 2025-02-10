#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output={{homedir}}/jupyterhub_%j.log
#SBATCH --error={{homedir}}/jupyterhub_%j.err
#SBATCH --time={{runtime}}
#SBATCH --nodes={{nodes}}
#SBATCH --ntasks={{ntasks}}
#SBATCH --qos={{qos}}
#SBATCH --partition={{cluster}}
#SBATCH --gres=gpu:{{gpus}}
#SBATCH --export=ALL
#SBATCH --constraint=""
#SBATCH --chdir={{homedir}}

set -euo pipefail
echo "Starting JupyterHub on Slurm node"

srun {{cmd}} --debug
