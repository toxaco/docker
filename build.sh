#!/usr/bin/env bash

# This build was only tested on macbook (IOS) host! 
# For linux and windows there need to be more tests! [05/2020]

clear

# This is the namespace to deploy the apps. Thanks to this you can have multiple versions of the same app.
read -p 'Please provide a namespace for this build (example: dev): ' COMPOSE_PROJECT_NAME
export COMPOSE_PROJECT_NAME

# The base infrastructure can't have multiple versions as they depend on specific ports (like 80, 3306).
export INFRA_CONTAINER_PREFIX="infra_";

# Execute all `./*/build.sh`.
for d in ./*/ ; do (cd "$d" && if [ ! -z "$(ls | grep build.sh)" ] ; then ./build.sh; fi); done

# clear

if [ ! -z "${COMPOSE_PROJECT_NAME}" ] ; then 
    docker ps -a --format '{{.Names}} | {{.Ports}}' | grep "${COMPOSE_PROJECT_NAME}_"
    echo "[Info] To access your apps use: http://${COMPOSE_PROJECT_NAME}.myAppName.com"
fi

docker ps -a --format '[{{.Names}}] Ports: {{.Ports}}' | grep "${INFRA_CONTAINER_PREFIX}"

echo "Build complete, enjoy!"