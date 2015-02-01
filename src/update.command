#!/bin/bash

#  update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-k8s-cluster/control
vagrant box update
vagrant up
#
cd ~/coreos-k8s-cluster/workers
vagrant box update
vagrant up

# download kubernetes binaries
cd ~/coreos-k8s-cluster/tmp
K8S_VERSION=$(curl --insecure -sS https://get.k8s.io | grep release= | cut -f2 -d"=")
echo "Downloading kubernetes $K8S_VERSION for OS X"
~/coreos-k8s-cluster/bin/wget -c https://github.com/GoogleCloudPlatform/kubernetes/releases/download/$K8S_VERSION/kubernetes.tar.gz
tar -xzvf kubernetes.tar.gz kubernetes/platforms/darwin/amd64
cp -f ./kubernetes/platforms/darwin/amd64/kubectl ~/coreos-k8s-cluster/bin
cp -f ./kubernetes/platforms/darwin/amd64/kubecfg ~/coreos-k8s-cluster/bin
# clean up tmp folder
rm -fr ~/coreos-k8s-cluster/tmp/*
rm -fr ~/coreos-k8s-cluster/tmp/.*
echo "kubecfg and kubectl were copied to ~/coreos-k8s-cluster/bin"
echo " "

# download latest versions of etcdctl, fleetctl and kubectl
cd ~/coreos-k8s-cluster/control
LATEST_RELEASE=$(vagrant ssh k8smaster-01 -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-k8s-cluster/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
echo "etcdctl was copied to ~/coreos-k8s-cluster/bin"
echo " "

#
cd ~/coreos-k8s-cluster/control
LATEST_RELEASE=$(vagrant ssh k8smaster-01 -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-k8s-cluster/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-k8s-cluster/bin "
echo " "

#
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
