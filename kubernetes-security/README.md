## Подготовка kubeconfig
Получите секрет, связанный с Service Account cd:
```
SECRET_NAME=$(kubectl get sa cd -n homework -o jsonpath="{.secrets[0].name}")
```

Извлеките токен из секрета:
```
TOKEN=$(kubectl get secret $SECRET_NAME -n homework -o jsonpath="{.data.token}" | base64 --decode)
```

Получите сертификат кластера:
```
CA_CRT=$(kubectl get secret $SECRET_NAME -n homework -o jsonpath="{.data['ca\.crt']}" | base64 --decode |  base64 -w 0)
```

Получите URL API сервера:
```
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```

Создайте kubeconfig файл:


Создайте файл kubeconfig-cd и добавьте в него следующее содержимое:
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CA_CRT
    server: $APISERVER
  name: default-cluster
contexts:
- context:
    cluster: default-cluster
    namespace: homework
    user: cd
  name: default-context
current-context: default-context
kind: Config
preferences: {}
users:
- name: cd
  user:
    token: $TOKEN
```

Замените переменные в kubeconfig файле:

Используйте команду envsubst для замены переменных в файле:
```
envsubst < kubeconfig-cd > kubeconfig-cd-final
```

Или просто запустить 
```
./prepare-kubeconfig.sh <имя пользователя>
```

## Cоздайте Service Account Token Secret с временем действия 1 день:

Используйте команду kubectl для создания токена с временем действия 1 день:
```
kubectl create token cd -n homework --duration=24h > token
```

## эндпоинту /metrics
```
kubectl apply -k kube-state-metrics
```

http://<kube-state-metrics-service>:8080/metrics