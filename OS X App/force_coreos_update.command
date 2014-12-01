#!/bin/bash

#  force_coreos_update.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-kubernetes-cluster/vagrant
vagrant up
vagrant ssh core-01 -c "sudo update_engine_client -update"
echo "Done with core-01 "
echo " "
vagrant ssh core-02 -c "sudo update_engine_client -update"
echo "Done with core-02 "
echo " "
vagrant ssh core-03 -c "sudo update_engine_client -update"
echo "Done with core-03 "
echo " "

echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
