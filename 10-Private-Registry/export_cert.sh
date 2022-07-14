#!/bin/bash

export MY_DOMAIN=k8s-example
export MY_NAMESPACE=container-registry
mkdir -p $HOME/temp/${MY_NAMESPACE}/cert-secrets


# cert_file - client certificate path used for authentication
kubectl get secret ${MY_DOMAIN}-com-cert-secret \
   --namespace ${MY_NAMESPACE} \
   -o jsonpath='{.data.tls\.crt}' | base64 -d \
   > $HOME/temp/${MY_NAMESPACE}/cert-secrets/cert_file.crt

# key_file - client key path used for authentication
kubectl get secret ${MY_DOMAIN}-com-cert-secret \
   --namespace ${MY_NAMESPACE} \
   -o jsonpath='{.data.tls\.key}' | base64 -d \
   > $HOME/temp/${MY_NAMESPACE}/cert-secrets/key_file.key

#ca_file - CA certificate path used to verify the remote server cert file
kubectl get secret ${MY_DOMAIN}-com-cert-secret \
   --namespace ${MY_NAMESPACE} \
   -o jsonpath='{.data.ca\.crt}' | base64 -d \
   > $HOME/temp/${MY_NAMESPACE}/cert-secrets/ca_file.crt

ls -lah $HOME/temp/${MY_NAMESPACE}/cert-secrets

unset MY_DOMAIN MY_NAMESPACE