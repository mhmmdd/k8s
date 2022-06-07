## Monitoring

## prometheus-operator
```shell
# go to: https://github.com/prometheus-operator/prometheus-operator
# go to: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
# go to: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 34.10.0

$ kubectl get deployments
$ kubectl port-forward deployment/my-kube-prometheus-stack-grafana 3000
```