#!/bin/bash

# Change these credentials to your own
export TRAEFIK_UI_USER=admin
export TRAEFIK_UI_PASS=123
export DESTINATION_FOLDER=${HOME}/temp/traefik-ui-creds

# Backup credentials to local files (in case you'll forget them later on)
mkdir -p ${DESTINATION_FOLDER}
echo $TRAEFIK_UI_USER >> ${DESTINATION_FOLDER}/traefik-ui-user.txt
echo $TRAEFIK_UI_PASS >> ${DESTINATION_FOLDER}/traefik-ui-pass.txt

htpasswd -Bbn ${TRAEFIK_UI_USER} ${TRAEFIK_UI_PASS} \
    > ${DESTINATION_FOLDER}/htpasswd

unset TRAEFIK_UI_USER TRAEFIK_UI_PASS DESTINATION_FOLDER