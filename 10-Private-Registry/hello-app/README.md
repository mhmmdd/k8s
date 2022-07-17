source: https://devopscube.com/configure-ingress-tls-kubernetes/
## Create Dev namespace and Apply hello-app
```shell
$ kubectl create namespace dev
#namespace/dev created

$ kubectl apply -f hello-app.yaml
#deployment.apps/hello-app created
#service/hello-service created

$ kubectl get all -n dev
#NAME                             READY   STATUS    RESTARTS   AGE
#pod/hello-app-78f957775f-hjznm   1/1     Running   0          20s
#pod/hello-app-78f957775f-smh82   1/1     Running   0          20s
#
#NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
#service/hello-service   ClusterIP   10.110.95.43   <none>        80/TCP    21s
#
#NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
#deployment.apps/hello-app   2/2     2            2           21s
#
#NAME                                   DESIRED   CURRENT   READY   AGE
#replicaset.apps/hello-app-78f957775f   2         2         2       21s
```

## Copy certificates
```shell
$ sudo cp -r /etc/letsencrypt/archive/kuruhurma.com /vagrant/copy-certificates
$ sudo cp -r /etc/letsencrypt/archive/kuruhurma.com/fullchain1.pem /etc/letsencrypt/archive/kuruhurma.com/privkey1.pem ${PWD}

$ bash << EOF
mv fullchain1.pem fullchain.pem
mv privkey1.pem privkey.pem
EOF
```

## Create a Secret according to the certificates
```shell
$ kubectl create secret tls k8s-kuruhurma-com-tls \
    --namespace dev \
    --key privkey.pem \
    --cert fullchain.pem
#secret/kuruhurma-com-tls created    

$ kubectl apply -f ingress.yaml 
#ingress.networking.k8s.io/hello-app-ingress created

# Optional
#$ kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

$ kubectl get services --all-namespaces
#NAMESPACE            NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
#dev                  hello-service                        ClusterIP      10.105.111.126   <none>          80/TCP                       175m
#ingress-nginx        ingress-nginx-controller             LoadBalancer   10.104.134.16    172.16.16.100   80:30419/TCP,443:30026/TCP   3h25m
#ingress-nginx        ingress-nginx-controller-admission   ClusterIP      10.102.29.179    <none>          443/TCP                      3h25m

$ kubectl get ing --all-namespaces
#NAMESPACE   NAME                CLASS   HOSTS               ADDRESS         PORTS     AGE
#dev         hello-app-ingress   nginx   k8s.kuruhurma.com   172.16.16.100   80, 443   165m

$ kubectl get ingress -n dev
#NAME                CLASS   HOSTS               ADDRESS   PORTS     AGE
#hello-app-ingress   nginx   k8s.kuruhurma.com             80, 443   13m

$ kubectl describe ing -n dev

$ echo -e "172.16.16.100\tk8s.kuruhurma.com" | sudo tee -a /etc/hosts
$ curl https://k8s.kuruhurma.com -kv
```