B```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
wget https://hashicorp-releases.yandexcloud.net/terraform/1.9.7/terraform_1.9.7_linux_amd64.zip
tar -xf terraform_1.9.7_linux_amd64.zip -C /usr/local/bin
rm /usr/local/bin/LICENSE.txt
```

Получить OUTH token
```
https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6---------------------9ec2fb
```


Устанавливаем Yndex CLI
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
yc init
yc resource-manager folder create --name otus --description "for OTUS homework"
```

Смотрим структуру
```
yc config list
```

Создаём отдельную папку
```
yc resource-manager folder create --name new-folder --description "my first folder with description"

```

Получить конфик кластера
```
yc managed-kubernetes cluster get-credentials k8scluster --external --folder-name otus
```

```
taint node cl1rpjcg3c9585j4r1e1-onad node-role=infra:NoSchedule

taint node cl1ifdbc7udsj6khn8sj-oqux node-role=infra:NoSchedule
```

```
helm install \
  --namespace <пространство_имен> \
  --create-namespace \
  --set loki-distributed.loki.storageConfig.aws.bucketnames=loki \
  --set loki-distributed.serviceaccountawskeyvalue_generated.accessKeyID= \
  --set loki-distributed.serviceaccountawskeyvalue_generated.secretAccessKey= \
  loki ./loki/