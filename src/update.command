#!/bin/bash

#  update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# get App's Resources folder
res_folder=$(cat ~/coreos-k8s-cluster/.env/resouces_path)

# copy gsed to ~/coreos-k8s-cluster/bin
cp -f "${res_folder}"/gsed ~/coreos-k8s-cluster/bin
chmod 755 ~/coreos-k8s-cluster/bin/gsed

# copy wget with https support to ~/coreos-k8s-cluster/bin
cp -f "${res_folder}"/wget ~/coreos-k8s-cluster/bin
chmod 755 ~/coreos-k8s-cluster/bin/wget

#
cd ~/coreos-k8s-cluster/control
vagrant up
#
cd ~/coreos-k8s-cluster/workers
vagrant up

# download latest versions of etcdctl and fleetctl
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
echo "Reinstalling updated fleet units to '~/coreos-k8s-cluster/fleet' folder:"
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
cd ~/coreos-k8s-cluster/fleet

#
if [ "$(diff "$res_folder"/fleet/fleet-ui.service ~/coreos-k8s-cluster/fleet/fleet-ui.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating fleet-ui.service!"
  cp -fr "$res_folder"/fleet/fleet-ui.service ~/coreos-k8s-cluster/fleet/fleet-ui.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy fleet-ui.service
  ~/coreos-k8s-cluster/bin/fleetctl start fleet-ui.service
fi

if [ "$(diff "$res_folder"/fleet/kube-apiserver.service ~/coreos-k8s-cluster/fleet/kube-apiserver.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-apiserver.service!"
  cp -fr "$res_folder"/fleet/kube-apiserver.service ~/coreos-k8s-cluster/fleet/kube-apiserver.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-apiserver.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-apiserver.service
fi

if [ "$(diff "$res_folder"/fleet/kube-controller-manager.service ~/coreos-k8s-cluster/fleet/kube-controller-manager.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-controller-manager.service!"
  cp -fr "$res_folder"/fleet/kube-controller-manager.service ~/coreos-k8s-cluster/fleet/kube-controller-manager.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-controller-manager.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-controller-manager.service
fi

if [ "$(diff "$res_folder"/fleet/kube-kubelet.service ~/coreos-k8s-cluster/fleet/kube-kubelet.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-kubelet.service!"
  cp -fr "$res_folder"/fleet/kube-kubelet.service ~/coreos-k8s-cluster/fleet/kube-kubelet.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-kubelet.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-kubelet.service
fi

if [ "$(diff "$res_folder"/fleet/kube-proxy.service ~/coreos-k8s-cluster/fleet/kube-proxy.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-proxy.service!"
  cp -fr "$res_folder"/fleet/kube-proxy.service ~/coreos-k8s-cluster/fleet/kube-proxy.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-proxy.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-proxy.service
fi

if [ "$(diff "$res_folder"/fleet/kube-register.service ~/coreos-k8s-cluster/fleet/kube-register.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-register.service!"
  cp -fr "$res_folder"/fleet/kube-register.service ~/coreos-k8s-cluster/fleet/kube-register.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-register.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-register.service
fi

if [ "$(diff "$res_folder"/fleet/kube-scheduler.service ~/coreos-k8s-cluster/fleet/kube-scheduler.service | tr -d '\n' | cut -c1-4 )" != "" ]
then
  echo "updating kube-scheduler.service!"
  cp -fr "$res_folder"/fleet/kube-scheduler.service ~/coreos-k8s-cluster/fleet/kube-scheduler.service
  ~/coreos-k8s-cluster/bin/fleetctl destroy kube-scheduler.service
  ~/coreos-k8s-cluster/bin/fleetctl start kube-scheduler.service
fi

echo "Finished updating fleet units"
~/coreos-k8s-cluster/bin/fleetctl list-units
echo " "

# set kubernetes master
export KUBERNETES_MASTER=http://172.17.15.101:8080
echo Waiting for Kubernetes cluster to be ready. This can take a few minutes...
spin='-\|/'
i=1
until ~/coreos-k8s-cluster/bin/kubectl version | grep 'Server Version' >/dev/null 2>&1; do printf "\b${spin:i++%${#sp}:1}"; sleep .1; done
i=0
until ~/coreos-k8s-cluster/bin/kubectl get nodes | grep 172.17.15.102 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
i=0
until ~/coreos-k8s-cluster/bin/kubectl get nodes | grep 172.17.15.103 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
echo " "
echo "k8s nodes list:"
~/coreos-k8s-cluster/bin/kubectl get nodes
echo " "


#
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
