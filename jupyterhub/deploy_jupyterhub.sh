kubectl create namespace jupyterhub
kubectl apply -f jupyterhub_metallb.yaml
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm install jupyterhub jupyterhub/jupyterhub -n jupyterhub -f ./values.yaml
#helm upgrade jupyterhub jupyterhub/jupyterhub -n jupyterhub -f ./values.yaml
