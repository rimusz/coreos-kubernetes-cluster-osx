#!/bin/bash

#  first-init.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.


### getting files from github and setting them up
echo ""
echo "Downloading latest coreos-vagrant files from github: "
git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-kubernetes-cluster/coreos-vagrant-github
echo "Done downloading from github !!!"
echo ""

# Vagrantfile
cp ~/coreos-kubernetes-cluster/coreos-vagrant-github/Vagrantfile ~/coreos-kubernetes-cluster/servers/control/Vagrantfile
cp ~/coreos-kubernetes-cluster/coreos-vagrant-github/Vagrantfile ~/coreos-kubernetes-cluster/servers/nodes/Vagrantfile

# change VM names to corekub-..
sed -i "" 's/core-%02d/corekub-control%02d/' ~/coreos-kubernetes-cluster/servers/control/Vagrantfile
sed -i "" 's/core-%02d/corekub-node%02d/' ~/coreos-kubernetes-cluster/servers/nodes/Vagrantfile
# change control IP to static
sed -i "" 's/172.17.8.#{i+100}/172.17.10.100/g' ~/coreos-kubernetes-cluster/servers/control/Vagrantfile
# change network subnet and IP to start from for nodes
sed -i "" 's/172.17.8.#{i+100}/172.17.10.#{i+101}/g' ~/coreos-kubernetes-cluster/servers/nodes/Vagrantfile

# change corekub-01 host ssh port forward
~/coreos-kubernetes-cluster/bin/gsed -i "/#config.vm.synced_folder/r $HOME/coreos-kubernetes-cluster/tmp/Vagrantfile.control" ~/coreos-kubernetes-cluster/servers/control/Vagrantfile
rm -f ~/coreos-kubernetes-cluster/tmp/Vagrantfile.control

# config.rb files
# control
cp ~/coreos-kubernetes-cluster/coreos-vagrant-github/config.rb.sample ~/coreos-kubernetes-cluster/servers/control/config.rb
###sed -i "" 's/#$vb_memory = 1024/$vb_memory = 512/' ~/coreos-kubernetes-cluster/servers/control/config.rb
# nodes
cp ~/coreos-kubernetes-cluster/coreos-vagrant-github/config.rb.sample ~/coreos-kubernetes-cluster/servers/nodes/config.rb
# set nodes to 2
sed -i "" 's/#$num_instances=1/$num_instances=2/' ~/coreos-kubernetes-cluster/servers/nodes/config.rb

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
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-kubernetes-cluster/servers/control/config.rb
        #
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-kubernetes-cluster/servers/nodes/config.rb
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
cd ~/coreos-kubernetes-cluster/servers/control
vagrant box update
vagrant up
#
cd ~/coreos-kubernetes-cluster/servers/nodes
vagrant up

# Add vagrant ssh key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key

# download etcdctl and fleetctl
#
cd ~/coreos-kubernetes-cluster/servers/control
LATEST_RELEASE=$(vagrant ssh corekub-control01 -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-kubernetes-cluster/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
# set etcd endpoint
export ETCD_ENDPOINT=172.17.10.100:4001
echo ""
etcdctl ls /
echo ""
#
cd ~/coreos-kubernetes-cluster/servers/control
LATEST_RELEASE=$(vagrant ssh corekub-control01 -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-kubernetes-cluster/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
# set fleetctl tunnel
export FLEETCTL_TUNNEL=127.0.0.1:2422
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines :"
fleetctl list-machines
echo ""
#
echo "Installing fleet units from '~/coreos-kubernetes-cluster/fleet' folder:"
cd ~/coreos-kubernetes-cluster/fleet
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
echo "Run from menu 'Up & OS Shell' to open a terninal window preset with fleetctl,etcdctl and kubectl to cluster settings"
echo ""
pause 'Press [Enter] key to continue...'


