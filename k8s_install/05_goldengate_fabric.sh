helm show values oggfree/goldengate-bigdata >ggfabric.yaml
#getting public address of nginx ingress controller
export EXTIP=$(kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {end}')
#putting the external address into the goldengate deployment
sed -i "s/ggate.xxx-xxx-xxx-xxx/ggfabric.${EXTIP// /}/g" ggfabric.yaml

#sample container pull secret, only required for GG bigdata
#  kubectl create secret docker-registry container-registry-secret -n microhacks  --docker-username=marcel.pfeifer@oracle.com --docker-password=yadayada --docker-server=container-registry.oracle.com


#BEFORE running the install, please exchange the target database connection string in gghack.yaml !!!

helm install oggfabric oggfree/goldengate-bigdata --values ggfabric.yaml -n microhacks

