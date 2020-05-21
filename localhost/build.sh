#!/usr/bin/env bash

DOCKER_ENV_CONTAINERS=$(docker ps --format '{{json .Names}}' | grep ${INFRA_CONTAINER_PREFIX} | paste -sd ' ' -);

# clear

if [ ! -z "$(ls | grep ${INFRA_CONTAINER_PREFIX})" ] ; then
  read -p "[warning] Do you want to backup the mariaDB first (can take a few minutes)? (y/n)?" choice
  case "$choice" in 
    y|Y ) zip -r "mariadb_backup.zip" "./${INFRA_CONTAINER_PREFIX}mariadb";;
  esac

  read -p "[danger] Clear infrastructure directory (including dbs, etc)? (y/n)?" choice
  case "$choice" in 
    y|Y ) rm -Rf "./${INFRA_CONTAINER_PREFIX}mariadb" && rm -Rf "./${INFRA_CONTAINER_PREFIX}portainer" && rm -Rf "./${INFRA_CONTAINER_PREFIX}redis" && rm -Rf "./${INFRA_CONTAINER_PREFIX}mysqlConfig";;
    n|N ) echo "ok";;
  esac
fi

# clear

if [ ! -z "$DOCKER_ENV_CONTAINERS" ] ; then
  read -p "[danger!] Purge all '${INFRA_CONTAINER_PREFIX}' containers (+stopped ones) as well as non used environment? (y/n)?" choice
  case "$choice" in 
    y|Y ) docker stop $(docker ps --format '{{.Names}}' | grep ${INFRA_CONTAINER_PREFIX}) && docker system prune -a --volumes --force;;
  esac
fi

# Make sure the necessary network exists.
docker network inspect "${INFRA_CONTAINER_PREFIX}dev" >/dev/null 2>&1  || docker network create "${INFRA_CONTAINER_PREFIX}dev";

# clear

read -p "Deploy ${INFRA_CONTAINER_PREFIX} containers? (y/n)?" choice
case "$choice" in 
  y|Y ) if [ ! -z "$DOCKER_ENV_CONTAINERS" ] ; then docker-compose down && docker-compose rm --force; fi && docker-compose up -d --build;;
esac

if [ ! -z "$(ls | grep -x mariadb_backup.zip)" ] ; then
  read -p "[info] Do you want to restore the available backup of mariaDB (can take a few minutes)? (y/n)?" choice
  case "$choice" in 
    y|Y ) rm -Rf "./${INFRA_CONTAINER_PREFIX}mariadb" && unzip "mariadb_backup.zip" -d "./";;
  esac
fi