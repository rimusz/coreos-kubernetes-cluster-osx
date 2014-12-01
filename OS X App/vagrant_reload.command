#!/bin/bash

#  vagrant_up.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-kubernetes-cluster/vagrant
vagrant reload

# path to the bin folder where we store our binary files
export PATH=$PATH:${HOME}/coreos-kubernetes-cluster/bin

# set fleetctl tunnel
# Add vagrant ssh key to ssh-agent
###vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
ssh-add ~/.vagrant.d/insecure_private_key
export FLEETCTL_TUNNEL=127.0.0.1:2422
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines :"
fleetctl list-machines

echo ""
echo "CoreOS Kubernetes Cluster was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
