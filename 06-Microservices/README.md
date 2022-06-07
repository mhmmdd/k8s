## Microservices
```shell
$ kubectl get all
$ kubectl apply -f workloads.yaml
$ kubectl get all
$ kubectl apply -f services.yaml

# go to: http://172.16.16.100:30010/admin/queues.jsp
# admin:admin

#Name  	           Number Of Pending Messages  	Number Of Consumers  	Messages Enqueued  	Messages Dequeued
#positionQueue	              31	                    1	                   6992	              6961	

# go to: http://172.16.16.100:30080/
```
