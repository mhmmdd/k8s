#!/bin/bash
export USER=$(cat $HOME/temp/registry-creds/registry-user.txt)
export PASSWORD=$(cat $HOME/temp/registry-creds/registry-pass.txt)

curl -kiv -H \
  "Authorization: Basic $(echo -n "${USER}:${PASSWORD}" | base64)" \
  https://registry.k8s-example.com/v2/_catalog
    
wget --no-check-certificate --header \
  "Authorization: Basic $(echo -n "${USER}:${PASSWORD}" | base64)" \
  https://registry.k8s-example.com/v2/_catalog
     
unset USER PASSWORD