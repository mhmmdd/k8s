Deployment has one additional feature rolling updates. Deployment can create ReplicaSets.
```shell
$ kubectl delete rs webapp
$ kubectl get all
$ kubectl apply -f pods.yaml
$ kubectl apply -f services.yaml

# deployment.apps/webapp     2/2     2            2           3s
# replicaset.apps/webapp-77896f4bf8     2         2         2       3s
```

```shell
# go to: http://172.16.16.100:30080
# go to: http://172.16.16.100:30010
```

## Rollout
```shell
$ kubectl rollout history deployment/webapp

# Change the version in the Pods.yaml
$ kubectl apply -f pods.yaml
$ kubectl rollout status deployment/webapp

#deployment.apps/webapp
#REVISION  CHANGE-CAUSE
#1         <none>
#2         <none>


$ kubectl rollout undo deployment/webapp --to-revision=1
# deployment.apps/webapp rolled back
```