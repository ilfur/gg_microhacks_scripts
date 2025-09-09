helm show values oggfree/autonomous-free >autonomous.yaml
#getting public address of nginx ingress controller
export EXTIP=$(kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {end}')
#putting the external address into the goldengate deployment
sed -i "s/131.189.32.182/${EXTIP// /}/g" autonomous.yaml


#BEFORE running the install, please exchange the database password in autonomous.yaml !
kubectl create namespace estateexplorer
helm install oggfabric oggfree/goldengate-autonomous --values autonomous.yaml -n estateexplorer
