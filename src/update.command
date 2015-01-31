#!/bin/bash

#  update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-k8s-cluster/servers/control
vagrant box update
vagrant up
#
cd ~/coreos-k8s-cluster/servers/nodes
vagrant up

# download latest coreos-vagrant
rm -rf ~/coreos-k8s-cluster/github
git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx-gui-k8s-cluster/github
echo "Downloads from github/vagrant are stored in ~/coreos-k8s-cluster/coreos-vagrant-github folder"
echo " "

# download latest versions of etcdctl, fleetctl and kubectl
cd ~/coreos-k8s-cluster/vagrant
LATEST_RELEASE=$(vagrant ssh corekub-01 -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-k8s-cluster/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
echo "etcdctl was copied to ~/coreos-k8s-cluster/bin "
#
cd ~/coreos-k8s-cluster/vagrant
LATEST_RELEASE=$(vagrant ssh corekub-01 -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-k8s-cluster/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-k8s-cluster/bin "
#
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
