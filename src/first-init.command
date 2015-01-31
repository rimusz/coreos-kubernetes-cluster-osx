#!/bin/bash

#  first-init.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.


### getting files from github and setting them up
echo ""
echo "Downloading latest coreos-vagrant files from github: "
git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-k8s-cluster/coreos-vagrant-github
echo "Done downloading from github !!!"
echo ""

# Vagrantfile
cp ~/coreos-k8s-cluster/coreos-vagrant-github/Vagrantfile ~/coreos-k8s-cluster/control/Vagrantfile
cp ~/coreos-k8s-cluster/coreos-vagrant-github/Vagrantfile ~/coreos-k8s-cluster/workers/Vagrantfile

# change VM names
sed -i "" 's/core-%02d/k8smaster%02d/' ~/coreos-k8s-cluster/control/Vagrantfile
sed -i "" 's/core-%02d/k8snode%02d/' ~/coreos-k8s-cluster/workers/Vagrantfile
# change control IP to static
sed -i "" 's/172.17.8.#{i+100}/172.17.15.101/g' ~/coreos-k8s-cluster/control/Vagrantfile
# change nodes network subnet and IP to start from
sed -i "" 's/172.17.8.#{i+100}/172.17.15.#{i+101}/g' ~/coreos-k8s-cluster/workers/Vagrantfile

# config.rb files
# control
cp ~/coreos-k8s-cluster/coreos-vagrant-github/config.rb.sample ~/coreos-k8s-cluster/control/config.rb
sed -i "" 's/#$instance_name_prefix="core"/$instance_name_prefix="k8smaster"/' ~/coreos-k8s-cluster/control/config.rb
sed -i "" 's/#$vm_memory = 1024/$vm_memory = 512/' ~/coreos-k8s-cluster/control/config.rb
# nodes
cp ~/coreos-k8s-cluster/coreos-vagrant-github/config.rb.sample ~/coreos-k8s-cluster/workers/config.rb
sed -i "" 's/#$instance_name_prefix="core"/$instance_name_prefix="k8snode"/' ~/coreos-k8s-cluster/workers/config.rb
# set nodes to 2
sed -i "" 's/#$num_instances=1/$num_instances=2/' ~/coreos-k8s-cluster/workers/config.rb

###


### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo "Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo "Select an option:"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-k8s-cluster/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-k8s-cluster/workers/config.rb
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-k8s-cluster/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-k8s-cluster/workers/config.rb
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-k8s-cluster/control/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-k8s-cluster/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-k8s-cluster/workers/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-k8s-cluster/workers/config.rb
        channel="Stable"
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel

#
function pause(){
read -p "$*"
}

# first up to initialise VMs
echo "Setting up Vagrant VMs for CoreOS Kubernetes Cluster on OS X"
cd ~/coreos-k8s-cluster/control
vagrant box update
vagrant up
#
cd ~/coreos-k8s-cluster/workers
vagrant up

# Add vagrant ssh key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key

# download etcdctl and fleetctl
#
cd ~/coreos-k8s-cluster/control
LATEST_RELEASE=$(vagrant ssh k8smaster-01 -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-k8s-cluster/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
# set etcd endpoint
export ETCDCTL_PEERS=http://172.17.15.101:4001
echo ""
etcdctl ls /
echo ""
#
cd ~/coreos-k8s-cluster/control
LATEST_RELEASE=$(vagrant ssh k8smaster-01 -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-k8s-cluster/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.17.15.101:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines :"
fleetctl list-machines
echo ""
#
echo "Installing fleet units from '~/coreos-k8s-cluster/fleet' folder:"
cd ~/coreos-k8s-cluster/fleet
~/coreos-osx/bin/fleetctl --strict-host-key-checking=false submit *.service
~/coreos-osx/bin/fleetctl --strict-host-key-checking=false start *.service
echo "Finished installing fleet units"
fleetctl list-units
echo " "

#
echo ""
echo "Installation has finished, CoreOS VMs are up and running !!!"
echo "Enjoy CoreOS-Vagrant Kubernetes Cluster on your Mac !!!"
echo ""
echo "Run from menu 'Up' to power up VM and open a terninal window preset with fleetctl,etcdctl and kubectl to cluster settings"
echo ""
pause 'Press [Enter] key to continue...'


