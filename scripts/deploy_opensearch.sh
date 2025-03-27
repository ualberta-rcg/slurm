kubectl create namespace opensearch-cluster
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update
helm install graylog-opensearch opensearch/opensearch -f opensearch-graylog-values.yaml -n opensearch-cluster
