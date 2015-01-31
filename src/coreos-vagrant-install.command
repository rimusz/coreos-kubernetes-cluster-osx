#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-kubernetes-cluster" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-k8s-cluster
    mkdir ~/coreos-k8s-cluster/coreos-vagrant-github
    mkdir ~/coreos-k8s-cluster/tmp
    mkdir ~/coreos-k8s-cluster/bin
    mkdir ~/coreos-k8s-cluster/fleet
    mkdir ~/coreos-k8s-cluster/kubernetes
    mkdir -p ~/coreos-k8s-cluster/control
    mkdir -p ~/coreos-k8s-cluster/workers

    # cd to App's Resources folder
    cd "$1"

    # copy gsed to ~/coreos--k8s--cluster/bin
    cp "$1"/gsed ~/coreos-k8s-cluster/bin
    chmod 755 ~/coreos-k8s-cluster/bin/gsed

    # copy other files
    # user-data files
    cp "$1"/Vagrantfiles/user-data.control ~/coreos-k8s-cluster/control/user-data
    cp "$1"/Vagrantfiles/user-data.node ~/coreos-k8s-cluster/workers/user-data

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-k8s-cluster/fleet

    # initial init
    open -a iTerm.app "$1"/first-init.command
