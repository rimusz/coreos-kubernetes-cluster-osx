#!/bin/bash

#  force_coreos_update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-kubernetes-cluster/servers/control
vagrant up
vagrant ssh corekub-01 -c "sudo update_engine_client -update"
echo "Done with corekub-01 "
echo " "
#
cd ~/coreos-kubernetes-cluster/servers/nodes
vagrant ssh corekub-02 -c "sudo update_engine_client -update"
echo "Done with corekub-02 "
echo " "
vagrant ssh corekub-03 -c "sudo update_engine_client -update"
echo "Done with corekub-03 "
echo " "

echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
