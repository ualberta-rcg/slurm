#!/bin/bash

# Namespace for the cluster
NAMESPACE="percona-db-cluster"

# Helm release names
OPERATOR_RELEASE="paice-op"
PXC_RELEASE="paice-db"

# Values file
VALUES_FILE="values.yaml"

# Check if the namespace exists
kubectl get namespace $NAMESPACE &>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating namespace: $NAMESPACE"
  kubectl create namespace $NAMESPACE
else
  echo "Namespace $NAMESPACE already exists."
fi

# Delete existing releases if they exist
echo "Deleting existing Helm releases..."
helm uninstall $PXC_RELEASE --namespace $NAMESPACE &>/dev/null
helm uninstall $OPERATOR_RELEASE --namespace $NAMESPACE &>/dev/null

# Wait for resources to terminate
echo "Waiting for resources to terminate..."
sleep 10

# Install the operator
echo "Installing the Percona XtraDB Cluster Operator..."
helm install $OPERATOR_RELEASE percona/pxc-operator --namespace $NAMESPACE

# Install the Percona XtraDB Cluster with custom values
echo "Installing the Percona XtraDB Cluster with custom values..."
# Namespace for the cluster
NAMESPACE="percona-db-cluster"

# Helm release names
OPERATOR_RELEASE="paice-op"
PXC_RELEASE="paice-db"

# Values file
VALUES_FILE="values.yaml"

echo "Installing the Percona XtraDB Cluster Operator..."
helm install $OPERATOR_RELEASE percona/pxc-operator --namespace $NAMESPACE

# Install the Percona XtraDB Cluster with custom values
echo "Installing the Percona XtraDB Cluster with custom values..."
helm install $PXC_RELEASE percona/pxc-db \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --set pxc.size=3 \
  --set pxc.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=db-node \
  --set pxc.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=In \
  --set pxc.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=true \
  --set haproxy.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key=db-node \
  --set haproxy.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator=In \
  --set haproxy.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]=true \
  --set pxc.configuration="[mysqld]\ninnodb_lock_wait_timeout=500\nmax_allowed_packet=67108864\ninnodb_buffer_pool_size=2147483648\ninnodb_redo_log_capacity=134217728"


# Wait for the pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --namespace $NAMESPACE --for=condition=ready pod --selector=app.kubernetes.io/instance=$PXC_RELEASE --timeout=300s

# Verify installation
echo "Verifying installation..."
kubectl get pods --namespace $NAMESPACE
kubectl get svc --namespace $NAMESPACE

ROOT_PASSWORD=$(kubectl -n percona-db-cluster get secret paice-db-pxc-db-secrets -o jsonpath="{.data.root}" | base64 --decode)
kubectl delete secret paice-db-pxc-db-secrets -n slurm
kubectl create secret generic paice-db-pxc-db-secrets   --from-literal=root="$ROOT_PASSWORD"   -n slurm

echo "Cluster setup completed successfully."
