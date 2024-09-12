## Установка ingress-контроллер nginx

k3s нужносначало установить без traefik-ingress
```
# Disable traefik
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh
```

## установка ingress-nginx (comunity)  nginx-ingress(F5)
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/baremetal/deploy.yaml
```
