#!/bin/bash

#  download_k8s.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

rm -f kubectl
rm -f *.tgz

# get latest k8s version
function get_latest_version_number {
local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/latest.txt"
if [[ $(which wget) ]]; then
wget -qO- ${latest_url}
elif [[ $(which curl) ]]; then
curl -Ss ${latest_url}
fi
}

K8S_VERSION=$(get_latest_version_number)

# download latest version of kubectl for OS X
echo "Downloading kubectl $K8S_VERSION for OS X"
../wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod 755 kubectl

# download latest version of k8s for CoreOS
# master
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-controller-manager
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
../wget -N -P ./master http://storage.googleapis.com/k8s/kube-register
tar czvf master.tgz -C master .
rm -f ./master/*

# nodes
../wget -N -P ./nodes https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
../wget -N -P ./nodes https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy
../wget -N -P ./master https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
tar czvf nodes.tgz -C nodes .
rm -f ./nodes/*

#
echo "Download has finished !!!"
pause 'Press [Enter] key to continue...'
