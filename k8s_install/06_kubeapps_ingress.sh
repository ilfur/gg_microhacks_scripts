#!/bin/bash
#getting public address of nginx ingress controller
export EXTIP=$(kubectl get service -n ingress-nginx -o jsonpath='{range .items[*]} {.status.loadBalancer.ingress[*].ip} {end}')

sed -i "s/kubeapps.84-235-173-41.nip.io/kubeapps.${EXTIP// /}/g" 06_kubeapps_ingress.yaml

kubectl apply -f 06_kubeapps_ingress.yaml
