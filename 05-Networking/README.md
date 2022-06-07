## Namespaces
```shell
$ kubectl get ns

#NAME                   STATUS   AGE
#default                Active   4d4h
#kube-node-lease        Active   4d4h
#kube-public            Active   4d4h
#kube-system            Active   4d4h

$ kubectl get pods -n kube-system
```
## Create an example Mysql Pod
```shell
# ClusterIP: App is running inside the cluster.
$ kubectl apply -f networking-tests.yaml

$ kubectl get pods -w
$ kubectl logs -f mysql
```

# How does the pod know what the mysql ip address?
```shell
$ kubectl exec -it webapp-77896f4bf8-lmmcw sh
$ cat /etc/resolv.conf
#search default.svc.cluster.local svc.cluster.local cluster.local
#nameserver 10.96.0.10
#options ndots:5

$ nslookup database
#nslookup: can't resolve '(null)': Name does not resolve
#
#Name:      database
#Address 1: 10.102.110.76 database.default.svc.cluster.local
```
