helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create namespace ingress-nginx
helm install nginx-quick ingress-nginx/ingress-nginx -n ingress-nginx --values nginx-values.yaml

#get external IP of nginx controller
kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {"\n"} {end}'

