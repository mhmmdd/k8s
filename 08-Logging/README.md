## Logging

## Install Helm
```shell
# go to: https://helm.sh/docs/intro/install/
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

## Install Ingress-Nginx
```shell
# go to: https://kubernetes.github.io/ingress-nginx/deploy/
$ helm upgrade --install ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx --create-namespace

$ kubectl get all --namespace=ingress-nginx
```

## Install MetalLB
```shell
# go to: https://metallb.universe.tf/installation/
# you see external-ip: pending
$ kubectl -n ingress-nginx get svc

$ cd metallb
$ helm repo add metallb https://metallb.github.io/metallb
$ helm install metallb metallb/metallb -f values.yaml

$ kubectl -n ingress-nginx get svc
```


```shell
$ kubectl apply -f fluentd-config.yaml
$ kubectl apply -f elastic-stack.yaml
$ kubectl apply -f storage.yaml
$ kubectl get all -n kube-system
$ kubectl get pods -n kube-system -w

$ kubectl get events -n kube-system

$ kubectl describe event elasticsearch-logging-0 --namespace kube-system
$ kubectl get events --all-namespaces  | grep -i elasticsearch
$ kubectl delete pods <pod_name> --grace-period=0 --force -n <namespace>
$ kubectl delete pods elasticsearch-logging-0 --grace-period=0 --force -n kube-system
```

## ELK Stack
https://www.youtube.com/watch?v=SU--XMhbWoY


## Logstash Config
logstash/values.yaml
```yaml
# go to : https://artifacthub.io/packages/helm/elastic/logstash/7.17.1
logstashPipeline:
  logstash.conf: |
    input {
      beats {
        port => 5044
      }
    }
    output { elasticsearch { hosts => "http://elasticsearch-master:9200" } }

service:
  annotations: {}
  type: ClusterIP
  loadBalancerIP: ""
  ports:
    - name: beats
      port: 5044
      protocol: TCP
      targetPort: 5044
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080
```

## Filebeat Config
filebeat/values.yaml
```yaml
# go to : https://artifacthub.io/packages/helm/elastic/filebeat/7.17.1
filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*.log
      processors:
      - add_kubernetes_metadata:
          host: ${NODE_NAME}
          matchers:
          - logs_path:
              logs_path: "/var/log/containers/"

    output.logstash:
      hosts: ["logstash-logstash:5044"]
```

## ElasticSearch Config
elasticsearch/values.yaml
```yaml
# go to : https://artifacthub.io/packages/helm/elastic/elasticsearch/7.17.1
replicas: 1
minimumMasterNodes: 1

resources:
  requests:
    cpu: "100m"
    memory: "1024M"
  limits:
    cpu: "1000m"
    memory: "1024M"

volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "standard"
  resources:
    requests:
      storage: 5Gi

# https://github.com/elastic/helm-charts/issues/258
extraInitContainers:
  - name: file-permissions
    image: busybox
    command: ['chown', '-R', '1000:1000', '/usr/share/elasticsearch/']
    volumeMounts:
      - mountPath: /usr/share/elasticsearch/data
        name: elasticsearch-master
    securityContext:
      privileged: true
      runAsUser: 0

antiAffinity: "soft"
```

## Kibana Config
kibana/values.yaml
```yaml
# go to : https://artifacthub.io/packages/helm/elastic/kibana/7.17.1

resources:
  requests:
    cpu: "100m"
    memory: "512M"
  limits:
    cpu: "1000m"
    memory: "512M"

healthCheckPath: "/api/status"

ingress:
  enabled: true
  pathtype: ImplementationSpecific
  annotations:
    kubernetes.io/ingress.class: nginx
  # kubernetes.io/tls-acme: "true"
  hosts:
    - host: kibana-example.local
      paths:
        - path: /
  #tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local
```

## Install
```shell
$ kubectl apply -f storage.yaml

# Filebeat
$ cd filebeat
$ helm install filebeat .
$ kubectl get pods --namespace=default -l app=filebeat-filebeat -w

# Logstash
$ cd ../
$ cd logstash
$ helm install logstash .
$ kubectl get pods --namespace=default -l app=logstash-logstash -w
$ kubectl get services

# Elasticsearch
$ cd ../
$ cd elasticsearch
$ helm install elasticsearch .
#1. Watch all cluster members come up.
#  $ kubectl get pods --namespace=default -l app=elasticsearch-master -w2. Test cluster health using Helm test.
#  $ helm --namespace=default test elasticsearch

# Kibana
$ cd ../
$ cd kibana
$ helm install kibana .
$ kubectl get services --all-namespaces

# Test
$ kubectl port-forward svc/elasticsearch-master 9200
$ curl localhost:9200/_cat/indices


## Test Kibana
$ kubectl get ingress
$ kubectl port-forward svc/kibana-kibana 8080:5601
# In the new cli
$ curl 127.0.0.1:8080/app/kibana

$ helm uninstall ingress-nginx -n ingress-nginx



# etc/host configuration
#C:\Windows\System32\drivers\etc\hosts
#172.16.16.100 kibana-example.local
# go to: http://kibana-example.local


$ kubectl exec -it logstash-logstash-0 bash
$ curl http://elasticsearch-master:9200
```

## Uninstall the Chart from Helm
```shell
$ helm ls 
$ helm uninstall kibana
```