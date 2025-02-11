#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output={{homedir}}/jupyterhub_%j.log
#SBATCH --error={{homedir}}/jupyterhub_%j.err
#SBATCH --time={{runtime}}
#SBATCH --partition={{partition}}
#SBATCH --ntasks={{ntasks}}
#SBATCH --gres=gpu:{{gpus}}
#SBATCH --cpus-per-task={{cores}}
#SBATCH --mem={{ram}}G
#SBATCH --export=ALL
#SBATCH --constraint=""
#SBATCH --chdir={{homedir}}

set -euo pipefail
echo "Starting JupyterHub on Slurm node"

srun {{cmd}} --debug
