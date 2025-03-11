# Use example-rke2-coredns.yaml as an example on how to add Hosts to Core DNS
# The following Command Edits the config map for CoreDNS
#kubectl -n kube-system edit configmap rke2-coredns-rke2-coredns
# The Following Command Applies the ConfigMap Edits
#kubectl -n kube-system rollout restart deployment rke2-coredns-rke2-coredns
