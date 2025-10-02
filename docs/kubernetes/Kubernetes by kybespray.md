# Порядок действий

Генерация и загрузка SSH ключей

```
ssh-keygen

ssh-copy-id kub@192.168.20.135
```

Config - файл

```
Host 192.168.20.135
	User kub
	ServerAliveInterval 60
	IdentityFile ~/.ssh/id_ed25519
```

Установка python, pip, git

```
sudo apt-get update -y
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update -y
sudo apt-get install git pip python3.11 -y
```

Установки менеджера пакетов PIP в Python

```
sudo -i
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py
```

Клонируем репозиторий  с github на сервер
https://github.com/kubernetes-sigs/kubespray

```
git clone https://github.com/kubernetes-sigs/kubespray
```

Выбираем релиз, в данном случае 2.26

```
git checkout release 2.26
```

Установка необходимых версий

```
cd kubespray/
pip3.11 install -r requirements.txt
```

Создаем свою папку

```
cp -rfp inventory/sample inventory/mycluster
```

Update Ansible inventory file with inventory builder

```
declare -a IPS=(10.128.0.28 10.128.0.35 10.128.0.11)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}
```

Copy private ssh key to ansible host 

```
scp -i ~/.ssh/yandex yandex yc-user@51.250.76.222:.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa
```

Запуск плейбука

```
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
```

После завершения плейбука в кластере, чтобы заработал

```
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

```
# if you faced problem with "Unable to connect to the server: x509: certificate is valid for XXX, not for XXX"
# then add "supplementary_addresses_in_ssl_keys" ips for file in inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
supplementary_addresses_in_ssl_keys: [1.1.1.1, 2.2.2.2]
```