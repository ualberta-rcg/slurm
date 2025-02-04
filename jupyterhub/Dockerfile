FROM jupyterhub/k8s-hub:4.1.0

USER root

# Install minimal Slurm tools needed for job submission
RUN apt-get update && apt-get install -y \
    slurm-client \
    iputils-ping \
    iproute2 \
    net-tools \
    dnsutils \
    traceroute \
    curl \
    wget \
    vim \
    nano \
    less \
    htop \
    lsof \
    tcpdump \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/jupyterhub/ || true 

COPY batch_template.sh /etc/jupyterhub/
COPY form_template.html /etc/jupyterhub/

# Install BatchSpawner
RUN pip install batchspawner \
    && pip cache purge

# The jupyterhub user is the default user in jupyterhub/jupyterhub image
USER jupyterhub
