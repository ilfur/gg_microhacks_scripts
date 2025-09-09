helm repo add avisto https://avistotelecom.github.io/charts/
kubectl create namespace cloudbeaver
helm install cloudbeaver avisto/cloudbeaver --version 1.0.1 -n cloudbeaver

export EXTIP=$(kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {end}')

echo "
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cloudbeaver-ingress
  namespace: cloudbeaver
spec:
  ingressClassName: nginx
  rules:
  - host: beaver.'$EXTIP'.nip.io
    http:
      paths:
      - backend:
          service:
            name: cloudbeaver
            port:
              number: 8978
        path: /
        pathType: Prefix
" | kubectl apply -f -
