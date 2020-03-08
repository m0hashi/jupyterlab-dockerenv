#!/bin/bash

cd configs
get_env(){
  #pass variable name in .env file to get the corresponding value in .env file.
  result=$(cat .env | grep $1 | cut -d "=" -f 2)
  echo $result
}

#run docker container with environment variables in .env

#run browser
SSHPORT=$(get_env SSHPORT)
NBPORT=$(get_env NBPORT)
WORKDIR=$(get_env WORKDIR)

if ! test -d $WORKDIR; then
  mkdir $WORKDIR
fi

docker-compose up &
sleep 1
firefox localhost:$NBPORT &
