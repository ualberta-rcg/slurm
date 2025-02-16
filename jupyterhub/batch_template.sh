#!/bin/bash
#SBATCH --job-name=spawner-jupyterhub
#SBATCH --output={{homedir}}/jupyterhub_slurmspawner_%j.log
#SBATCH --error={{homedir}}/jupyterhub_slurmspawner_%j.err
#SBATCH --time={{runtime}}
#SBATCH --partition={{partition}}
#SBATCH --ntasks={{ntasks}}
#SBATCH --gres=gpu:{{gpus}}
#SBATCH --cpus-per-task={{cores}}
#SBATCH --mem={{ram}}G
#SBATCH --export={{keepvars}}
#SBATCH --get-user-env=L
#SBATCH --constraint=""
#SBATCH --chdir={{homedir}}

set -euo pipefail
echo "Starting JupyterHub on Slurm node"

export SLURM_TMPDIR=/tmp/slurm.${SLURM_JOBID}
mkdir -p "${SLURM_TMPDIR}"

# Make sure Jupyter does not store its runtime in the home directory
export JUPYTER_RUNTIME_DIR=${SLURM_TMPDIR}/jupyter

# Setup user pip install folder
export PIP_PREFIX=${SLURM_TMPDIR}
export PATH="${PIP_PREFIX}/bin":${PATH}
export PYTHONPATH="/cvmfs/soft.computecanada.ca/custom/python/envs/jupyterhub_node/v4.3.13/lib/usercustomize"

# Make sure the environment-level directories does not
# have priority over user-level directories for config and data.
# Jupyter core is trying to be smart with virtual environments
# and it is not doing the right thing in our case.
export JUPYTER_PREFER_ENV_PATH=0

module load ipython-kernel

srun {{cmd}} --debug
