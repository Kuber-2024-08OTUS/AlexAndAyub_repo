```
helm repo list
helm repo update
helm search repo kafka
bitnami/kafka
helm pull bitnami

helm plugin install https://github.com/databus23/helm-diff
helmfile init
helm applay
helm uninstall kafka-dev -n dev && helm uninstall kafka-prod -n prod


helm upgrade -i kafka bitnami/kafka -f kafka/values_prod.yaml -n prod --create-namespace
helm upgrade -i kafka bitnami/kafka -f kafka/values_dev.yaml -n dev --create-namespace


helm list -n homework
helm upgrade --install homework homework --namespace homework
helm template homework homework -n  homework> result.yml
```