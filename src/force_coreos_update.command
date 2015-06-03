#!/bin/bash

#  force_coreos_update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-k8s-cluster/control
vagrant up
vagrant ssh k8smaster-01 -c "sudo update_engine_client -update"
echo "Done with k8smaster-01 "
echo " "
#
cd ~/coreos-k8s-cluster/workers
vagrant up
vagrant ssh k8snode-01 -c "sudo update_engine_client -update"
echo "Done with k8snode-01 "
echo " "
vagrant ssh k8snode-02 -c "sudo update_engine_client -update"
echo "Done with k8snode-02 "
echo " "

echo "Update has finished !!!"
echo "You need to reboot machines if CoreOS update was successful"
echo "Just use 'Reload' from the App menu"
pause 'Press [Enter] key to continue...'
