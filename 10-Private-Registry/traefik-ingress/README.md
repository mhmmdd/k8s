source: https://blog.zachinachshon.com/traefik-ingress/
## Install traefik
```shell
$ kubectl create namespace traefik
$ helm repo add traefik https://helm.traefik.io/traefik
$ helm repo update

$ helm search repo traefik
#NAME            CHART VERSION   APP VERSION     DESCRIPTION                                  
#traefik/traefik 10.24.0         2.8.0           A Traefik based Kubernetes ingress controller

$ helm upgrade --install traefik \
    --namespace traefik \
    --set dashboard.enabled=true \
    --set rbac.enabled=true \
    --set nodeSelector.node-type=master \
    --set="additionalArguments={--api.dashboard=true,--log.level=INFO,--providers.kubernetesingress.ingressclass=traefik-internal,--serversTransport.insecureSkipVerify=true}" \
    traefik/traefik \
    --version 10.24.0
```
## Verify installation
```shell
# Make sure all traefik deployed pods are running
kubectl get pods --namespace traefik

# Make sure custom resources *.traefik.containo.us were created successfully
kubectl get crd | grep traefik
```

## Copy secret to traefik namespace
```shell
$ kubectl get secret k8s-example-com-cert-secret -n cert-manager -o yaml \
| sed s/"namespace: cert-manager"/"namespace: traefik"/\
| kubectl apply -n traefik -f -
# secret/k8s-example-com-cert-secret configured

$ kubectl get secret k8s-example-com-cert-secret -o yaml -n traefik
```

## Install Traefik Dashboard
```shell
$ sudo apt-get update
$ sudo apt-get install apache2-utils

$ ./generate_user_password.sh
$ ls ${HOME}/temp/traefik-ui-creds
#htpasswd  traefik-ui-pass.txt  traefik-ui-user.txt
$ cat ${HOME}/temp/traefik-ui-creds/traefik-ui-user.txt
$ cat ${HOME}/temp/traefik-ui-creds/traefik-ui-pass.txt
$ cat ${HOME}/temp/traefik-ui-creds/htpasswd

$ kubectl create secret generic traefik-dashboard-auth-secret \
   --from-file=$HOME/temp/traefik-ui-creds/htpasswd \
   --namespace traefik

$ kubectl get secret traefik-dashboard-auth-secret -o yaml --namespace traefik

$ kubectl apply -f traefik-dashboard.yaml
#ingressroute.traefik.containo.us/traefik-dashboard configured
#middleware.traefik.containo.us/traefik-dashboard-auth created
```
## Check that resources were created successfully
```shell
# IngressRoute
$ kubectl describe ingressroute traefik-dashboard --namespace traefik

# Middleware
$ kubectl describe middleware traefik-dashboard-auth --namespace traefik

$ kubectl logs -f $(kubectl get pods --namespace traefik | grep "^traefik" | awk '{print $1}') --namespace traefik
```
## Set a hosted name traefik.MY_DOMAIN.com on a client machine (laptop/desktop)
```shell
$ kubectl get svc -n traefik
#NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
#traefik   LoadBalancer   10.98.112.140   172.16.16.102   80:31944/TCP,443:30864/TCP   3h11m

# Edit the file using `sudo /etc/hosts`
# for windows: C:\Windows\System32\drivers\etc
# Append manualy to the existing k3s hosted name
172.16.16.102 kmaster, traefik.k8s-example.com

# Alternatively, add a new hosted name entry with a one-liner
$ echo -e "172.16.16.102\ttraefik.k8s-example.com" | sudo tee -a /etc/hosts

# go to: https://traefik.k8s-example.com/dashboard/#/
```
## Uninstall
```shell
# 1. Remove traefik from the cluster
helm uninstall traefik --namespace traefik
   
# 2. Clear the traefik namespace
kubectl delete namespaces traefik
```