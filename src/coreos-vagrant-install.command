#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-kubernetes-cluster" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-kubernetes-cluster
    mkdir ~/coreos-kubernetes-cluster/coreos-vagrant-github
    mkdir ~/coreos-kubernetes-cluster/tmp
    mkdir ~/coreos-kubernetes-cluster/bin
    mkdir ~/coreos-kubernetes-cluster/fleet
    mkdir ~/coreos-kubernetes-cluster/kubernetes
    mkdir -p ~/coreos-kubernetes-cluster/servers/control
    mkdir -p ~/coreos-kubernetes-cluster/servers/nodes

    # cd to App's Resources folder
    cd "$1"

    # copy gsed to ~/coreos--kubernetes--cluster/bin
    cp "$1"/gsed ~/coreos-kubernetes-cluster/bin
    chmod 755 ~/coreos-kubernetes-cluster/bin/gsed

    # copy files to ~/coreos-kubernetes-cluster/tmp for later use of first-init.command
    # Vagrantfile
    cp "$1"/Vagrantfiles/Vagrantfile.control ~/coreos-kubernetes-cluster/tmp/Vagrantfile.control

    # copy other files
    # user-data files
    cp "$1"/Vagrantfiles/user-data.control ~/coreos-kubernetes-cluster/servers/control/user-data
    cp "$1"/Vagrantfiles/user-data.node ~/coreos-kubernetes-cluster/servers/nodes/user-data

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-kubernetes-cluster/fleet

    # copy kubernetes json files
    cp -R "$1"/kubernetes/ ~/coreos-kubernetes-cluster/kubernetes


    # initial init
    open -a iTerm.app "$1"/first-init.command
