kubectl create namespace percona-mongo-cluster
helm install mongodb-operator percona/psmdb-operator --namespace percona-mongo-cluster
helm install mongodb-graylog percona/psmdb-db --namespace percona-mongo-cluster -f percona-mongodb-graylog-values.yaml
