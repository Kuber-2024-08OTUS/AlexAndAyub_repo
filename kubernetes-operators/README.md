Delete a CustomResourceDefinition
```
k apply -f ./kubernetes-operators/deployment.yaml
k apply -f ./kubernetes-operators/mysql-custom-object.yaml
k get mysqls.otus.homework -n homework
k delete -f ./kubernetes-operators/crd.yaml
```

go install

```
wget https://go.dev/dl/go1.21.13.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.13.linux-amd64.tar.gz
```

operator-sdk prepare
```
apt install make
export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
export OS=$(uname | awk '{print tolower($0)}')
export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.37.0
curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}

chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk

go mod init mysql-operator
operator-sdk init --domain --plagins go --domain otus.homework
operator-sdk create api --group ops --version v1alpha1 --kind Project
make manifests
```

https://habr.com/ru/articles/710588/