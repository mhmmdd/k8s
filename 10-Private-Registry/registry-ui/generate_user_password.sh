#!/bin/bash

# Change these credentials to your own
export REGISTRY_UI_USER=admin
export REGISTRY_UI_PASS=123
export DESTINATION_FOLDER=${HOME}/temp/registry-ui-creds

# Backup credentials to local files (in case you'll forget them later on)
mkdir -p ${DESTINATION_FOLDER}
echo ${REGISTRY_UI_USER} >> ${DESTINATION_FOLDER}/registry-ui-user.txt
echo ${REGISTRY_UI_PASS} >> ${DESTINATION_FOLDER}/registry-ui-pass.txt

htpasswd -Bbn ${REGISTRY_UI_USER} ${REGISTRY_UI_PASS} \
    > ${DESTINATION_FOLDER}/htpasswd

unset REGISTRY_UI_USER REGISTRY_UI_PASS DESTINATION_FOLDER