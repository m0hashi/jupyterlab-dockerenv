#!/bin/bash
rm .env & touch .env

echo "UID=$(id -u $UID)" >> .env
echo "GID=$(id -g $UID)" >> .env
echo "UNAME=$USER" >> .env
echo "UPASSWD=password" >> .env
echo "NBPORT=8888" >> .env
echo "SSHPORT=11111" >> .env
mkdir workspace
mkdir ~/.kaggle
mkdir ~/.aws