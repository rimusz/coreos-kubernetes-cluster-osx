#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-kubernetes-cluster" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-kubernetes-cluster
    mkdir ~/coreos-kubernetes-cluster/coreos-vagrant-github
    mkdir ~/coreos-kubernetes-cluster/github
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

    # copy .gitignore
    cp "$1"/gitignore ~/coreos-kubernetes-cluster/github/.gitignore

    # copy files to ~/coreos-kubernetes-cluster/tmp for later use of first-init.command
    # Vagrantfile
    cp "$1"/Vagrantfile.control ~/coreos-kubernetes-cluster/tmp/Vagrantfile.control
    # config.rb file
    cp "$1"/config.rb.control ~/coreos-kubernetes-cluster/tmp/config.rb.control

    # initial init
    open -a iTerm.app "$1"/first-init.command
