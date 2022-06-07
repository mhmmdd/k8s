Apply yaml to Kubernetes
```shell
$ kubectl get all
$ kubectl create -f first-pod.yaml
$ kubectl create -f webapp-service.yaml
```

```shell
$ kubectl get all
$ kubectl describe service/fleetman-webapp
# Selector: app=webapp,release=0-5
# NodePort: http  30080/TCP

# go to: http://172.16.16.100:30080/
```

### Selector -l
```shell
$ kubectl get pods --show-labels
# webapp                      1/1     Running   0          10m     app=webapp,release=0
# webapp-release-0-5          1/1     Running   0          10m     app=webapp,release=0-5

$ kubectl get pods --show-labels -l release=0
# webapp                      1/1     Running   0          10m     app=webapp,release=0
```