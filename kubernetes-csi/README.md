terraform apply

yc iam service-account list --foldef-name opus

kubectl --kubeconfig /root/.kube/config create -f secret.yaml
kubectl --kubeconfig /root/.kube/config create -f k8s-csi-s3/deploy/kubernetes/provisioner.yaml
kubectl --kubeconfig /root/.kube/config create -f k8s-csi-s3/deploy/kubernetes/driver.yaml
kubectl --kubeconfig /root/.kube/config create -f k8s-csi-s3/deploy/kubernetes/csi-s3.yaml
kubectl --kubeconfig /root/.kube/config  create -f storageclass.yaml

kubectl --kubeconfig /root/.kube/config apply -f pv-static.yaml
kubectl --kubeconfig /root/.kube/config apply -f pvc-static.yaml
kubectl --kubeconfig /root/.kube/config apply -f pod-static.yaml
kubectl --kubeconfig /root/.kube/config get pods

kubectl --kubeconfig /root/.kube/config exec -ti csi-s3-test-nginx-static -- echo "Hi OTUS" > /s3/otus.txt