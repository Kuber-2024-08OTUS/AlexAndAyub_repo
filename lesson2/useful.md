## Install zsh
```
apt update && sudo apt upgrade -y sudo apt install git zsh vim
or
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```
from https://ohmyz.sh/#install

```
vim ~/.zshrc
  plugins-(git helm kubectl)
```

## Install Oh my posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

## Настройка PuTTY
Скачать шрифт MesloLGS
PuTTY -> Windows -> Apperance -> Font (выбрать MesloLGS)

## Установка K3S
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -

## Полезные команды
https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/  
