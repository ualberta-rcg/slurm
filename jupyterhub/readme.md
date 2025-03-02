# JupyterHub on Slurm Cluster

This directory contains configuration files to deploy JupyterHub on a Slurm cluster using Helm, BatchSpawner, and FormSpawner. Users log in, fill out a form to specify job parameters, and launch JupyterLab instances as Slurm jobs, with the UI relayed back via BatchSpawner. JupyterLab is sourced from CVMFS repositories.

## Overview
- **Purpose**: Multi-user JupyterHub deployment on a Slurm cluster.
- **Components**: Helm chart configuration, Slurm job templates, user form, and Docker image setup.
- **Deployment**: Uses `helm upgrade` with custom `values.yaml`.
- **Namespace**: `jupyterhub` (Kubernetes namespace for deployment).

## Prerequisites
- Kubernetes cluster with Helm installed.
- Slurm cluster configured and accessible.
- CVMFS repositories set up for JupyterLab.
- Private LDAP settings (Must update `values.yaml` with the correct settings).

## Directory Contents
| File                  | Purpose                                                                 |
|-----------------------|-------------------------------------------------------------------------|
| `Dockerfile`          | Builds the JupyterHub container image with Slurm integration.           |
| `batch_template.sh`   | Slurm job script template, populated from user form inputs.             |
| `form_template.html`  | HTML form for users to specify job parameters (e.g., CPUs, memory).     |
| `jupyterhub_metallb.yaml` | MetalLB configuration for load balancing the JupyterHub service.       |
| `values.yaml`         | Helm configuration file (key settings; LDAP settings separate).         |

## Deployment Order
Deploying JupyterHub involves setting up the namespace, building the image, and applying configurations in sequence. Follow these steps:

### 1. Create the Kubernetes Namespace
```bash
kubectl create namespace jupyterhub
```
- **Why**: Isolates JupyterHub resources in the `jupyterhub` namespace for better organization and security.

### 2. Build the Docker Image ( Optional )
```bash
docker build -t jupyterhub-slurm:latest -f jupyterhub/Dockerfile .
docker push jupyterhub-slurm:latest  # Push to your registry
```
- **Explanation**: The `Dockerfile` creates a container image with JupyterHub, BatchSpawner, and Slurm dependencies. Push it to a container registry accessible by your Kubernetes cluster.
- **Note**: Update `values.yaml` with the image tag if using a custom registry.

### 3. Apply MetalLB Configuration (Optional)
```bash
kubectl apply -f jupyterhub/jupyterhub_metallb.yaml -n jupyterhub
```
- **Explanation**: Configures MetalLB for load balancing, assigning an external IP to the JupyterHub service. Skip if using a different load balancer or exposing the service another way.

### 4. Deploy JupyterHub with Helm
```bash
helm upgrade jupyterhub jupyterhub/jupyterhub -n jupyterhub -f jupyterhub/values.yaml --install
```
- **Explanation**: Deploys JupyterHub using the Helm chart (assumed at `jupyterhub/jupyterhub`), with `values.yaml` providing custom settings like BatchSpawner configuration. The `--install` flag ensures installation if not already present.
- **Note**: Adjust the chart path if it differs in your setup (e.g., a local chart directory).

### 5. Verify Deployment
```bash
kubectl get pods -n jupyterhub
kubectl get svc -n jupyterhub
```
- **Why**: Confirms the JupyterHub pod is running and the service is accessible (check the external IP if using MetalLB).

## Component Details
### `values.yaml`
- **Role**: Core configuration file for Helm, defining spawner settings (BatchSpawner for Slurm), hub details, and more.
- **Customization**: Add private LDAP settings here or via a separate secret. Adjust resource limits and Slurm options as needed.

### `Dockerfile`
- **Role**: Builds the JupyterHub image, embedding Slurm tools and dependencies.
- **Nuance**: Includes Slurm in the image (e.g., `slurm-client`), ensuring compatibility with the cluster.

### `batch_template.sh`
- **Role**: Template for Slurm job scripts, filled with user inputs (e.g., `#SBATCH --ntasks={{ ntasks }}`).
- **Process**: BatchSpawner submits this script to Slurm, launching JupyterLab.

### `form_template.html`
- **Role**: User-facing form for job parameters, integrated via FormSpawner or WrapSpawner.
- **Output**: Populates `batch_template.sh` with values like CPU count or runtime.

### `jupyterhub_metallb.yaml`
- **Role**: Configures MetalLB to expose JupyterHub within our private Slurm Cluster Network. Allows JupyterHub to Submit Slurm Jobs.

## Additional Notes
- **CVMFS**: JupyterLab runs from CVMFS repos, requiring cluster nodes to have CVMFS configured.
- **LDAP**: Private settings must be added separately (e.g., via the Values.yaml file).
- **Troubleshooting**: Check pod logs (`kubectl logs -n jupyterhub <pod-name>`) if login or job submission fails.
