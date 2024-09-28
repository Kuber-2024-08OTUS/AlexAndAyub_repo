Delete a CustomResourceDefinition
```
k apply -f ./kubernetes-operators/deployment.yaml
k apply -f ./kubernetes-operators/mysql-custom-object.yaml
k get mysqls.otus.homework -n homework
k delete -f ./kubernetes-operators/crd.yaml
```