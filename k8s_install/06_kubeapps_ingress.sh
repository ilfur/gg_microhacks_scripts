#!/bin/bash

sed -i "s/kubeapps.84-235-173-41.nip.io/kubeapps.${EXTIP// /}/g" 06_kubeapps_ingress.yaml

kubectl apply -f 06_kubeapps_ingress.yaml
