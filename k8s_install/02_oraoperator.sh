kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/refs/heads/main/rbac/cluster-role-binding.yaml
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/refs/heads/main/oracle-database-operator.yaml
