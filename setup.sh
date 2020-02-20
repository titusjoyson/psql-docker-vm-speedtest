#!/bin/bash
echo "setup sysbench" 
sudo apt -y install make automake libtool pkg-config libaio-dev
sudo apt -y install libpq-dev
sudo apt insall pg-activity
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench

echo "Setup Docker"
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

echo "setup postgresql"
sourcePath="/etc/apt/sources.list.d/pgdg.list"
repoPath="deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main"

if ! grep -q "$repoPath" $sourcePath;
then
    sudo touch /etc/apt/sources.list.d/pgdg.list
    sudo sh -c "echo '$repoPath' >> $sourcePath"
fi
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - 
sudo apt update
sudo apt install postgresql-11