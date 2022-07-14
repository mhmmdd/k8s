source: https://blog.zachinachshon.com/cert-manager/#self-signed-certificate
## Install Certificate
```shell
# source: https://cert-manager.io/docs/installation/helm/
$ helm repo add jetstack https://charts.jetstack.io
#"jetstack" has been added to your repositories
$ helm repo update

$ helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.8.2 \
  --set installCRDs=true
  
#NAME: cert-manager
#LAST DEPLOYED: Thu Jul 14 07:38:05 2022
#NAMESPACE: cert-manager
#STATUS: deployed
#REVISION: 1
#TEST SUITE: None
#NOTES:
#cert-manager v1.8.2 has been deployed successfully!
#
#In order to begin issuing certificates, you will need to set up a ClusterIssuer
#or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).
#
#More information on the different types of issuers and how to configure them
#can be found in our documentation:
#
#https://cert-manager.io/docs/configuration/
#
#For information on how to configure cert-manager to automatically provision
#Certificates for Ingress resources, take a look at the `ingress-shim`
#documentation:
#
#https://cert-manager.io/docs/usage/ingress/
```
## Verify installation
```shell
# Make sure all cert-manager deployed pods are running
kubectl get pods --namespace cert-manager
   
# Make sure custom resources *.cert-manager.io were created successfully 
kubectl get crd | grep cert-manager
    
# Verify that ClusterIssuer is non-namespaced scoped ('false')
# so it can be used to issue Certificates across all namespaces
kubectl api-resources | grep clusterissuers
```

## Uninstall
```shell
#1. Remove cert-manager from the cluster
$ helm uninstall cert-manager --namespace cert-manager

#2. Clear the namespace
$ kubectl delete namespaces cert-manager
```

## Apply Issuer 
```shell
# MY_DOMAIN=k8s-example
# MY_NAMESPACE=cert-manager

#MY_DOMAIN-com-cert-secret
$ kubectl apply -f cluster-issuer.yaml
#clusterissuer.cert-manager.io/k8s-example-ca-issuer created

$ kubectl get clusterissuers k8s-example-ca-issuer -o wide
#NAME                    READY   STATUS   AGE
#k8s-example-ca-issuer   True             37
```

## Apply Certificate
```shell
# MY_DOMAIN=k8s-example
# MY_NAMESPACE=cert-manager

$ kubectl apply -f certificate.yaml
#certificate.cert-manager.io/k8s-example-ca created

$ kubectl get certificate --namespace cert-manager
#NAME                   READY   SECRET                        AGE
#k8s-example-com-cert   True    k8s-example-com-cert-secret   28s


# Check certificate status is Issued
$ kubectl describe certificate k8s-example-com-cert --namespace cert-manager
#Events:
#  Type    Reason     Age   From                                       Message
#  ----    ------     ----  ----                                       -------
#  Normal  Issuing    26s   cert-manager-certificates-trigger          Issuing certificate as Secret was previously issued by ClusterIssuer.cert-manager.io/k8s-example-ca-issuer        
#  Normal  Reused     26s   cert-manager-certificates-key-manager      Reusing private key stored in existing Secret resource "k8s-example-com-cert-secret"
#  Normal  Requested  25s   cert-manager-certificates-request-manager  Created new CertificateRequest resource "k8s-example-com-cert-hg2lb"
#  Normal  Issuing    25s   cert-manager-certificates-issuing          The certificate has been successfully issued

$ kubectl get secret --namespace cert-manager
$ kubectl get secret k8s-example-com-cert-secret -o yaml --namespace cert-manager
```

## Copy secret to container-registry namespace
```shell
$ kubectl get secret k8s-example-com-cert-secret -n cert-manager -o yaml \
| sed s/"namespace: cert-manager"/"namespace: container-registry"/\
| kubectl apply -n container-registry -f -
# secret/k8s-example-com-cert-secret configured

$ kubectl get secret k8s-example-com-cert-secret -o yaml -n container-registry
```

## (Optional): When in need to delete a certificate
```shell
# Delete certificate
kubectl delete certificate k8s-example-com-cert --namespace cert-manager
   
# Delete the auto generated secret
kubectl delete secret k8s-example-com-cert-secret --namespace cert-manager
```