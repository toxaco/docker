#!/usr/bin/env bash

if [ -z "${COMPOSE_PROJECT_NAME}" ] ; then echo "No namespace to build!" && exit 1; fi

# Make sure this is unique to this app!
export APP_CONTAINER_NAME="${COMPOSE_PROJECT_NAME}_myapp";

export PROXY_CURRENT_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' ${INFRA_CONTAINER_PREFIX}proxy);
export MARIADB_CURRENT_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "3306/tcp") 0).HostPort}}' ${INFRA_CONTAINER_PREFIX}mariadb);
export APP_CONTAINER=$(docker ps --format '{{json .Names}}' | grep ${APP_CONTAINER_NAME} | paste -sd ' ' -);

# clear

if [ ! -z "$(ls | grep ${COMPOSE_PROJECT_NAME}_)" ] ; then
  read -p "[danger!] Remove APP files ${COMPOSE_PROJECT_NAME}_app (for fresh intalation)? (y/n)?" choice
  case "$choice" in 
    y|Y ) rm -Rf "./${COMPOSE_PROJECT_NAME}_app";;
  esac
fi

# clear

read -p "Build fresh ${APP_CONTAINER_NAME} container? (y/n)?" choice
case "$choice" in 
  y|Y ) if [ ! -z "$APP_CONTAINER" ] ; then docker stop $(docker ps --format '{{.Names}}' | grep ${APP_CONTAINER_NAME}) && docker-compose rm --force; fi && docker-compose up -d --build;;
esac

# clear

read -p "Have you added the DNS to your (current machine and not the container) /etc/hosts? (127.0.0.1 ${COMPOSE_PROJECT_NAME}.mydomain.com >> /etc/hosts) (y/n)?" choice
case "$choice" in 
  y|Y ) python -m webbrowser "${COMPOSE_PROJECT_NAME}.mydomain.com";;
esac

# clear