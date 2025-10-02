Подготовка

Заходим в файл
```
kubectl edit configmap -n kube-system kube-proxy
```

Поменять значение
```
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

```
:/strictARP
Нажимаем i
меняем на значение true
esc
:wq
```

С помощью манифеста устанавливаем metallb

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```

Проверка, что установлено

```
kubectl -n metallb-system get pods

kubectl api-resources | grep metallb 
```

Создаем адрес пул

первый pool-1.yml файл:

```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.20.136-192.168.20.136
```

второй l2-advertisement.yml файл:

```
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2pool
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

команда:

```
kubectl -n metallb-system apply -f pool-1.yml

kubectl -n metallb-system get IPAddressPool

kubectl apply -f l2-advertisement.yml
```