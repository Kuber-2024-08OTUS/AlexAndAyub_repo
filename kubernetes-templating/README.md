helm list -n homework
helm upgrade --install homework homework --namespace homework
helm template homework homework -n  homework> result.yml
