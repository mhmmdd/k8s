source: http://blog.zachinachshon.com/docker-registry/
## Create Persistent Volume
```shell
$ alias k="kubectl"
$ k create namespace container-registry
#namespace/container-registry created

$ k apply -f pvc.yaml
#persistentvolume/docker-registry-pv created
#persistentvolumeclaim/docker-registry-pv-claim created

$ k get pv docker-registry-pv
#NAME                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS                    REASON   AGE
#docker-registry-pv   10Gi       RWO            Delete           Available           docker-registry-local-storage            21s

$ k get pvc docker-registry-pvc --namespace container-registry
#NAME                  STATUS   VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
#docker-registry-pvc   Bound    docker-registry-pv   10Gi       RWO            docker-registry-local-storage   7m32s
```

## Create mount directory on kmaster node
```shell
$ cd /mnt
$ sudo mkdir container-registry
$ sudo chmod 777 container-registry
```
## Install Docker
```shell
$ ./install_docker.sh
$ ./generate_user_password.sh
$ ls ${HOME}/temp/registry-creds
#htpasswd  registry-pass.txt  registry-user.txt
$ cat ${HOME}/temp/registry-creds/registry-pass.txt
```
## Label the master node
```shell
$ k get nodes --show-labels
$ k label nodes kmaster node-type=master
#node/kmaster labeled

$ k get nodes --show-labels | grep node-type
```
## Install twuni
```shell
$ helm repo add twuni https://helm.twun.io
$ helm repo update
$ helm search repo docker-registry
#NAME                    CHART VERSION   APP VERSION     DESCRIPTION                     
#twuni/docker-registry   2.1.0           2.7.1           A Helm chart for Docker Registry

$ helm upgrade --install docker-registry \
    --namespace container-registry \
    --set replicaCount=1 \
    --set persistence.enabled=true \
    --set persistence.size=10Gi \
    --set persistence.deleteEnabled=true \
    --set persistence.storageClass=docker-registry-local-storage \
    --set persistence.existingClaim=docker-registry-pvc \
    --set secrets.htpasswd=$(cat $HOME/temp/registry-creds/htpasswd) \
    --set nodeSelector.node-type=master \
    twuni/docker-registry \
    --version 2.1.0
    
#1. Get the application URL by running these commands:
#  export POD_NAME=$(kubectl get pods --namespace container-registry -l "app=docker-registry,release=docker-registry" -o jsonpath="{.items[0].metadata.name}")
#  echo "Visit http://127.0.0.1:8080 to use your application"
#  kubectl -n container-registry port-forward $POD_NAME 8080:5000

$ k get pods -n container-registry | grep docker-registry
docker-registry-679698c77b-wx6w6   0/1     Pending   0          98s

$ k describe pod docker-registry-679698c77b-wx6w6 -n container-registry

$ k get pod/docker-registry-679698c77b-wx6w6  -n container-registry -o json


$ k taint nodes kmaster node-role.kubernetes.io/master-
#node/kmaster untainted
```
## Uninstall
```shell
#1. Remove docker-registry from the cluster
$ helm uninstall docker-registry --namespace container-registry

#2. Clear the container-registry namespace
$ k delete namespaces container-registry
```
## Create a self-signed certificate as described in [here](certificate/README.md) under container-registry namespace.
## Install traefik as described in [here](traefik-ingress/README.md) under traefik namespace.

## Create an IngressRoute
```shell
$ kubectl apply -f ingress-route.yaml
#ingressroute.traefik.containo.us/docker-registry created
#middleware.traefik.containo.us/docker-registry-cors created

$ kubectl describe ingressroute docker-registry --namespace container-registry
```

## Set a hosted name registry.MY_DOMAIN.com on a client machine (laptop/desktop)
```shell
$ kubectl get svc -n traefik
#NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
#traefik   LoadBalancer   10.98.112.140   172.16.16.102   80:31944/TCP,443:30864/TCP   3h11m

# Edit the file using `sudo /etc/hosts`
# for windows: C:\Windows\System32\drivers\etc
# Append manualy to the existing k3s hosted name
172.16.16.102 kmaster, registry.k8s-example.com

# Alternatively, add a new hosted name entry with a one-liner
$ echo -e "172.16.16.102\tregistry.k8s-example.com" | sudo tee -a /etc/hosts
# go to: https://registry.k8s-example.com/v2/_catalog
```
## Verify registry address
```shell
$ ./verify-registry.sh
#Saving to: ‘_catalog’
#
#_catalog                                      100%[=================================================================================================>]      20  --.-KB/s    in 0s       
#
#2022-07-14 12:49:41 (1.60 MB/s) - ‘_catalog’ saved [20/20]
```
## Install docker-registry-ui as described in [here](registry-ui/README.md) under container-dashboard namespace.

## Export certificates
```shell
$ ./export_cert.sh
#-rw-rw-r-- 1 vagrant vagrant    0 Jul 14 15:12 ca_file.crt
#-rw-rw-r-- 1 vagrant vagrant    0 Jul 14 15:12 cert_file.crt
#-rw-rw-r-- 1 vagrant vagrant    0 Jul 14 15:12 key_file.key
```
## Copy the certificate secrets (cert_file, key_file, ca_file) to each of the cluster nodes
```shell
$ ls -l $HOME/temp/container-registry/cert-secrets

# Install sshpass
$ sudo apt-get install sshpass

# Copy client certificate, client key, CA certificate
$ sshpass -p "vagrant" scp -r $HOME/temp/container-registry/cert-secrets vagrant@kworker1:/tmp/container-registry
$ sshpass -p "vagrant" scp -r $HOME/temp/container-registry/cert-secrets vagrant@kworker2:/tmp/container-registry
```
## 
```shell
# Append to kmaster node hosts file
$ echo -e "172.16.16.102\tregistry.k8s-example.com" | sudo tee -a /etc/hosts
$ sshpass -p "vagrant" ssh vagrant@kworker1 \
    "echo -e '172.16.16.102\tregistry.k8s-example.com' | sudo tee -a /etc/hosts"
$ sshpass -p "vagrant" ssh vagrant@kworker2 \
    "echo -e '172.16.16.102\tregistry.k8s-example.com' | sudo tee -a /etc/hosts"
```

## Docker Login
```shell
docker login \
   -u $(cat $HOME/temp/registry-creds/registry-user.txt) \
   -p $(cat $HOME/temp/registry-creds/registry-pass.txt) \
   https://registry.k8s-example.com
```
## Use custom tls/ssl [here](certbot/README.md)
## Create an example app with using generated tls/ssl [here](hello-app/README.md)
