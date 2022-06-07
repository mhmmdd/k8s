## [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

```shell
$ kubectl get all
$ kubectl apply -f .

$ kubectl get pods -w
#api-gateway-6494b87d9c-72pj5          0/1     ContainerCreating   0          56s
#mongodb-6f98dc97cf-2b6dh              0/1     ContainerCreating   0          57s
#position-simulator-784c7d7686-hhgdh   0/1     ContainerCreating   0          57s
#position-tracker-64b7b5c6c-f84j9      0/1     ContainerCreating   0          56s
#queue-6c49f58687-4grcx                0/1     ContainerCreating   0          57s
#webapp-644f7b68-75zqt                 0/1     ContainerCreating   0          56s
```
## Spring Boot MongoDB settings
```properties
# see: https://github.com/DickChesterwood/k8s-fleetman/blob/release3/k8s-fleetman-position-tracker/src/main/resources/application-production-microservice.properties

spring.activemq.broker-url=tcp://fleetman-queue.default.svc.cluster.local:61616
fleetman.position.queue=positionQueue

# We'll use the default port 8080 for all microservices in production cluster.

# TODO but this is reasonable guess! This may change when we scale it out...
spring.data.mongodb.host=fleetman-mongodb.default.svc.cluster.local
```

mongo-stack.yaml is default setting. 
If you want to use EBS, this file will be the **same**.
```yaml
spec:
  containers:
    - name: mongodb
      image: mongo:3.6.5-jessie
      volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
  volumes:
    - name: mongo-persistent-storage
      # pointer to the configuration of HOW we want the mount to be implemented
      persistentVolumeClaim:
        claimName: mongo-pvc
```

PersistentVolumeClaim
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pvc
spec:
  storageClassName: mylocalstorage
  accessModes:
    - ReadWriteOnce # read-write by a single node
  resources:
    requests:
      storage: 20Gi
```
Volume Access Modes:
1. ReadWriteOnce: read-write by a single node.
2. ReadOnlyMany: read-only by many nodes.
3. ReadWriteMany: read-write by many nodes.
4. ReadWriteOncePod: read-write by a single Pod.

## Mount Path
```shell
$ kubectl get pv
#NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS     REASON   AGE
#local-storage   20Gi       RWO            Retain           Bound    default/mongo-pvc   mylocalstorage            95m

$ kubectl get pvc
#NAME        STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS     AGE
#mongo-pvc   Bound    local-storage   20Gi       RWO            mylocalstorage   96m

$ kubectl get all
$ kubectl describe pod/mongodb-6f98dc97cf-2b6dh
# Mounts:
#      /data/db from mongo-persistent-storage (rw)
#      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hv2zh (ro)
```
