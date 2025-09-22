#getting public address of nginx ingress controller
export EXTIP=$(kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {end}')
helm repo add oggfree https://ilfur.github.io/VirtualAnalyticRooms
helm show values oggfree/goldengate-microhack-sample >gghack.yaml
#putting the external address into the goldengate deployment
sed -i "s/xxx-xxx-xxx-xxx/${EXTIP// /}/g" gghack.yaml

# create the namespace everything goes into
kubectl create namespace microhacks

#sample container pull secret, only required for GG bigdata/distributed apps
#  kubectl create secret docker-registry container-registry-secret -n microhacks  --docker-username=marcel.pfeifer@oracle.com --docker-password=yadayada --docker-server=container-registry.oracle.com


#create secret for OGG admin user and password to-be-created
kubectl create secret generic ogg-admin-secret -n microhacks \
  --from-literal=oggusername=ggadmin \
  --from-literal=oggpassword=Welcome1234# \

  #create secret for source and target database admin and ogg users to be created (target must be there already!)
kubectl create secret generic db-admin-secret -n microhacks \
  --from-literal=srcAdminPwd=Welcome1234# \
  --from-literal=trgAdminPwd="MySecretPassword123!" \
  --from-literal=srcGGUserName=ggadmin \
  --from-literal=trgGGUserName=ggadmin \
  --from-literal=srcGGPwd=Welcome1234# \
  --from-literal=trgGGPwd=Welcome1234# 

#BEFORE running the install, please exchange the target database connection string in gghack.yaml !!!

helm install ogghack oggfree/goldengate-microhack-sample --values gghack.yaml -n microhacks

