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

jupyter lab --no-browser --port=${port} --ip=0.0.0.0
