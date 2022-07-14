Source: https://www.virtualizationhowto.com/2021/06/kubernetes-dashboard-helm-installation-and-configuration/
## Run the application
```shell
# Add kubernetes-dashboard repository
$ helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
$ helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard

# echo https://127.0.0.1:8443/
# kubectl -n default port-forward $POD_NAME 8443:8443


$ KUBE_EDITOR="nano" kubectl edit svc kubernetes-dashboard
# add nodePort: 32001 after the targetPort: https
# change the type: ClusterIP to type: NodePort

# go to: https://172.16.16.100:32001/#/login

$ kubectl describe sa kubernetes-dashboard
#Image pull secrets:  <none>
#Mountable secrets:   kubernetes-dashboard-token-kcw92
#Tokens:              kubernetes-dashboard-token-kcw92
# get the token: kubernetes-dashboard-token-kcw92

$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^deployment-controller-token-/{print $1}') | awk '$1=="token:"{print $2}' > token.txt
#$ kubectl -n kube-system describe secrets `kubectl -n kube-system get secrets | awk '/clusterrole-aggregation-controller/ {print $1}'` | awk '/token:/ {print $2}'
```
```shell
$ kubectl create -f dashboard-rb.yaml 
```