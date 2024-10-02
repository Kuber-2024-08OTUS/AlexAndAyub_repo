helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm search repo prometheus-community
create namespace monitoring

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml