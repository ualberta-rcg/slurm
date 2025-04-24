# Create Dirs on Each Host
# mkdir /mnt/pg-zabbix # or whatever we are going to use on each host
# chmod 777 -R /mnt/pg-zabbix

#kubectl create namespace percona-pg-cluster
#helm repo add percona https://percona.github.io/percona-helm-charts/
#helm repo update
#helm install pg-operator percona/pg-operator --namespace percona-pg-cluster
#kubectl apply -f percona-pg-zabbix-pv.yaml
#helm upgrade --install pg-zabbix-cluster percona/pg-db --namespace percona-pg-cluster -f percona-pg-zabbix-values.yaml
#kubectl -n percona-pg-cluster get all
#kubectl get pvc -n percona-pg-cluster
#kubectl get secrets -n percona-pg-cluster
#kubectl get perconapgcluster -n percona-pg-cluster
#kubectl get pv
#ls /mnt/pg-zabbix/
