
```
helm pull oci://ghcr.io/nginx/charts/nginx-ingress --untar --version 2.1.0

ls nginx-ingress

kubectl apply -f crds/

kubectl create namespace nginx-ingress

helm install nginx-ingress oci://ghcr.io/nginx/charts/nginx-ingress --version 2.1.0 --namespace nginx-ingress
```
