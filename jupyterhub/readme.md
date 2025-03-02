# JupyterHub on Slurm Cluster

This repository provides a setup for deploying **JupyterHub** on a **Slurm cluster**, enabling multiple users to run **JupyterLab** sessions as Slurm jobs. Users log in, specify job parameters (e.g., CPU, memory) via a form, and launch JupyterLab sessions on allocated cluster resources. This is ideal for research, education, or multi-user environments requiring scalable computational access.

The deployment integrates **Helm** for Kubernetes management, **NFS** for shared configurations, **LDAP** for authentication, **cvmfs** for software access, and **MetalLB** for networking, ensuring seamless communication with the Slurm scheduler.

## Features
- **Customizable Job Submission**: Users define resource needs (CPU, memory, etc.) through a form.
- **Slurm Integration**: Sessions run as Slurm jobs via batch and form spawners.
- **Scalable Storage**: Dynamic NFS-based storage for user sessions.
- **Secure Authentication**: LDAP integration via `sssd` for user management.
- **Software Access**: Leverages `cvmfs` for pre-installed scientific software.

## Prerequisites
Before deploying, ensure the following are set up:
- A configured **Slurm cluster** for job scheduling.
- **NFS shares** for configurations:
  - Slurm config: `/etc/slurm`
  - Munge key: `/mnt/nfs-munge`
  - `sssd` config: `/etc/sssd`
- An **LDAP server** integrated with `sssd` for authentication.
- **cvmfs** configured for software access (e.g., JupyterLab binaries).
- A Kubernetes cluster with a dynamic **storage class** named `nfs-client`.
- Installed dependencies: `sssd`, `munge`, and Slurm client tools (on host or in container).

## Directory Contents
| File                  | Purpose                                                                 |
|-----------------------|-------------------------------------------------------------------------|
| `Dockerfile`          | Builds the JupyterHub container image with Slurm integration.           |
| `batch_template.sh`   | Slurm job script template, populated from user form inputs.             |
| `form_template.html`  | HTML form for users to specify job parameters (e.g., CPUs, memory).     |
| `jupyterhub_metallb.yaml` | MetalLB configuration for load balancing the JupyterHub service.       |
| `values.yaml`         | Helm configuration file.         |


## Deployment Steps

### 1. Build the Container Image (Optional)
Build the Docker image containing JupyterHub, Slurm tools, `sssd`, and `munge`:

```bash
docker build -t rkhoja/slurm:jupyterhub .
```

> **Note**: rkhoja/slurm:jupyterhub already exists at https://hub.docker.com/repository/docker/rkhoja/slurm/general .

### 2. Configure NFS Shares and Authentication
Set up NFS mounts for shared configurations:
- **Slurm Config**: Mount at `/etc/slurm`.
- **Munge Key**: Mount at `/mnt/nfs-munge` for secure communication. The Munge key is copied into place via Values.yaml extra config.
- **sssd Config**: Mount at `/etc/sssd` for LDAP authentication. This is needed along with the LDAP setting within the Values.yaml.

Update the `sssd` configuration in `/etc/sssd` to connect to your LDAP server. Refer to the [SSSD Documentation](https://sssd.io/docs/) for details.

### 3. Customize Helm Values
Edit the provided `values.yaml` file:
- **LDAP Settings**: Update the private LDAP settings (e.g., server, bind DN) to match your environment.
- **NFS Mounts**: Verify paths for `nfs-slurm-config`, `nfs-munge-key`, and `nfs-sssd`.
- **Image**: Set to `rkhoja/slurm:jupyterhub` with `pullPolicy: Always`.

### 4. Deploy with Helm
Follow these steps to deploy JupyterHub:

#### a. Create Namespace
Create a Kubernetes namespace for JupyterHub:
```bash
kubectl create namespace jupyterhub
```

#### b. Apply MetalLB Configuration
Apply the MetalLB configuration to expose JupyterHub on the internal Slurm network, allowing it to submit jobs:
```bash
kubectl apply -f jupyterhub_metallb.yaml
```
> **Note**: Ensure MetalLB is installed in your cluster. It enables communication between JupyterHub and Slurm.

#### c. Update Helm Repository
Add the JupyterHub Helm chart repository:
```bash
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
```

#### d. Install JupyterHub
Deploy JupyterHub using Helm:
```bash
helm upgrade --install jupyterhub jupyterhub/jupyterhub -n jupyterhub -f values.yaml
```

### 5. Verify Deployment
- Get Kubernetes pod and service details:
  ```bash
      kubectl get pods -n jupyterhub
      kubectl get svc -n jupyterhub
  ```
- Access JupyterHub via the service URL provided by Hub, usually Cluster IP (e.g., `http://<hub-connect-ip>`).

## Usage
1. Users log in via the JupyterHub URL using LDAP credentials.
2. Fill out the form (`form_template.html`) to specify job parameters (e.g., CPU, memory).
3. Submit the form to launch a JupyterLab session as a Slurm job.
4. Work in JupyterLab, with the UI relayed back through the hub.

## Customization
- **Job Script**: Modify `batch_template.sh` for custom Slurm directives.
- **Form**: Edit `form_template.html` to adjust input fields or options.

## Networking Details
**MetalLB** exposes JupyterHub on the internal Slurm network (e.g., `172.16.254.39` as per `values.yaml`). This allows JupyterHub to communicate with Slurm for job submission and management.

## Troubleshooting
- **Logs**: Check `kubectl -n jupyterhub logs <pod-name>` for errors.
- **Slurm Access**: Ensure the cluster is reachable and the munge key is correct.
- **LDAP**: Verify `sssd` settings and NFS mounts.
- **NFS**: Confirm mounts are accessible in the container.

## Notes
- **cvmfs**: Software is sourced from `cvmfs`, which needs to be installed on the Slurm hosts.
- **GitHub Workflows**: Included for development (e.g., `extract_jupyter_debs.yml`), not deployment.

## Resources
- [JupyterHub Helm Chart](https://jupyterhub.github.io/helm-chart/)
- [SSSD Documentation](https://sssd.io/docs/)
- [MetalLB Documentation](https://metallb.universe.tf/)
- [Munge Project](https://dun.github.io/munge/)


