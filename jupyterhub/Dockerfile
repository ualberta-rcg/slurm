FROM jupyterhub/jupyterhub:latest

USER root

# Install minimal Slurm tools needed for job submission
RUN apt-get update && apt-get install -y \
    slurm-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install BatchSpawner
RUN pip install batchspawner \
    && pip cache purge

# Copy custom configuration files
COPY jupyterhub_config.py /srv/jupyterhub/

# The jupyterhub user (not jovyan) is the default user in jupyterhub/jupyterhub image
USER jupyterhub

# The default working directory in jupyterhub/jupyterhub is already /srv/jupyterhub
