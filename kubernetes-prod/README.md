# master

```
swapoff -a
sed -i '/swap/s/^/#\ /'  /etc/fstab


export CRIO_VERSION=1.28
export OS=xUbuntu_22.04

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

apt update
apt install cri-o cri-o-runc -y

systemctl enable crio
systemctl start crio
systemctl status crio

crictl --runtime-endpoint unix:///var/run/crio/crio.sock version

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF


sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubeadm

kubeadm init --service-dns-domain=otusminkov.ru --upload-certs


mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

```

# Worker
```
export CRIO_VERSION=1.28
export OS=xUbuntu_22.04

swapoff -a
sed -i '/swap/s/^/#\ /'  /etc/fstab

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

apt update
apt install cri-o cri-o-runc -y

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm
apt-mark hold kubeadm

kubeadm join 10.128.0.12:6443 --token <data> --discovery-token-ca-cert-hash sha256:<data>

```

```
#> kubectl get nodes -o wide

NAME                             STATUS   ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
m1-vm-2-8-50-hdd                 Ready    control-plane   13h   v1.28.15   10.128.0.12   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w1-vm-2-8-50-hdd-1732989321077   Ready    <none>          12h   v1.28.15   10.128.0.32   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w2-vm-2-8-50-hdd-1732989366621   Ready    <none>          12h   v1.28.15   10.128.0.25   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w3-vm-2-8-50-hdd-1732989393929   Ready    <none>          12h   v1.28.15   10.128.0.5    <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
```

# Обновление
```
killall -s SIGTERM kube-apiserver

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-mark unhold kubeadm
apt-get update && sudo apt-get install -y kubeadm
apt-mark hold kubeadm

kubeadm upgrade plan
kubeadm upgrade apply v1.29.11


apt-mark unhold kubelet kubectl
apt-get update && sudo apt-get install -y kubelet
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

```

# Обновление worker node
```
kubectl get nodes -o wide
kubectl drain <node nameexit> --ignore-daemonsets

apt-mark unhold kubeadm kubelet
apt-get update && sudo apt-get install -y kubeadm kubelet
apt-mark hold kubelet kubeadm

systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon w1-vm-2-8-50-hdd-1732989321077
```

```
kubectl get nodes -o wide
NAME                             STATUS   ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
m1-vm-2-8-50-hdd                 Ready    control-plane   13h   v1.29.11   10.128.0.12   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w1-vm-2-8-50-hdd-1732989321077   Ready    <none>          13h   v1.29.11   10.128.0.32   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w2-vm-2-8-50-hdd-1732989366621   Ready    <none>          13h   v1.29.11   10.128.0.25   <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
w3-vm-2-8-50-hdd-1732989393929   Ready    <none>          13h   v1.29.11   10.128.0.5    <none>        Ubuntu 24.04.1 LTS   6.8.0-49-generic   cri-o://1.28.4
```