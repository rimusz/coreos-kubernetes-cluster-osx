#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Cluster for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-kubernetes-cluster" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-kubernetes-cluster
    mkdir ~/coreos-kubernetes-cluster/vagrant
    mkdir ~/coreos-kubernetes-cluster/tmp
    mkdir ~/coreos-kubernetes-cluster/bin
    mkdir ~/coreos-kubernetes-cluster/fleet
    mkdir ~/coreos-kubernetes-cluster/kubernetes

    # download latest vagrant
    git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx-gui-kubernetes-cluster/github

    # cd to App's Resources folder
    cd "$1"

    # copy gsed to ~/coreos-kubernetes-cluster/bin
    cp "$1"/gsed ~/coreos-kubernetes-cluster/bin

    # Vagrantfile
    cp ~/coreos-kubernetes-cluster/github/Vagrantfile ~/coreos-kubernetes-cluster/vagrant/Vagrantfile
    # change core-01 host ssh port forward
    cp "$1"/Vagrantfile ~/coreos-kubernetes-cluster/tmp/Vagrantfile
    "$1"/gsed -i "/#config.vm.synced_folder/r $HOME/coreos-kubernetes-cluster/tmp/Vagrantfile" ~/coreos-kubernetes-cluster/vagrant/Vagrantfile
    rm -f ~/coreos-kubernetes-cluster/tmp/Vagrantfile

    # config.rb file
    # enable discovery setup
    cat "$1"/config.rb ~/coreos-kubernetes-cluster/github/config.rb.sample > ~/coreos-kubernetes-cluster/vagrant/config.rb
    # set a size of the CoreOS cluster created by Vagrant to 3
    sed -i "" 's/#$num_instances=1/$num_instances=3/' ~/coreos-kubernetes-cluster/vagrant/config.rb

    # user-data file
    cp ~/coreos-kubernetes-cluster/github/user-data.sample ~/coreos-kubernetes-cluster/vagrant/user-data

    # initial init
    open -a iTerm.app "$1"/first-init.command
