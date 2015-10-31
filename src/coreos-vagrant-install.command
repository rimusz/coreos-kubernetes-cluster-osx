#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# create symbolic link for vagrant to work on OS X 10.11
ln -s /opt/vagrant/bin/vagrant /usr/local/bin/vagrant >/dev/null 2>&1

# create in "coreos-k8s-cluster" all required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-k8s-cluster/tmp
    mkdir ~/coreos-k8s-cluster/bin
    mkdir ~/coreos-k8s-cluster/fleet
    mkdir ~/coreos-k8s-cluster/kubernetes
    mkdir -p ~/coreos-k8s-cluster/control
    mkdir -p ~/coreos-k8s-cluster/workers

    # cd to App's Resources folder
    cd "$1"

    # copy gsed to ~/coreos-k8s-cluster/bin
    cp "$1"/gsed ~/coreos-k8s-cluster/bin

    # copy wget with https support to ~/coreos-k8s-cluster/bin
    cp "$1"/wget ~/coreos-k8s-cluster/bin

    # copy kubectl to ~/coreos-k8s-cluster/bin
    cp "$1"/kubectl ~/coreos-k8s-cluster/bin

    # copy gen_kubeconfig to ~/coreos-k8s-cluster/bin
    cp "$1"/gen_kubeconfig ~/coreos-k8s-cluster/bin
    #
    chmod 755 ~/coreos-k8s-cluster/bin/*

    # copy other files
    # user-data files
    cp "$1"/Vagrantfiles/user-data.control ~/coreos-k8s-cluster/control/user-data
    cp "$1"/Vagrantfiles/user-data.node ~/coreos-k8s-cluster/workers/user-data

    # copy k8s files
    cp "$1"/k8s/kubectl ~/coreos-k8s-cluster/control
    chmod 755 ~/coreos-k8s-cluster/control/kubectl
    cp "$1"/k8s/*.yaml ~/coreos-k8s-cluster/kubernetes
    # linux binaries
    cp "$1"/k8s/master.tgz ~/coreos-k8s-cluster/control
    cp "$1"/k8s/nodes.tgz ~/coreos-k8s-cluster/workers

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-k8s-cluster/fleet

    # initial init
    open -a iTerm.app "$1"/first-init.command
