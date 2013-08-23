Description
===========

Installs and configures CDH4 with YARN on a Single Linux Node in Pseudo-distributed mode.

Requirements
============

Platform
--------

* Ubuntu
 
Tested on:

* Ubuntu 12.04 Precise 3.2.0-23-generic x86_64

Vagrant setup example
---------------------

    # -*- mode: ruby -*-
    # vi: set ft=ruby :
    
    VAGRANTFILE_API_VERSION = "2"
    
    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.box = "precise64"
      config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    
      config.vm.network :forwarded_port, guest: 50070, host: 50070  
      config.vm.network :forwarded_port, guest: 50075, host: 50075  
    
    
      config.vm.provision :chef_solo do |chef|
        chef.add_recipe "apt"
        chef.add_recipe "java"
        chef.add_recipe "pseudo_distributed_cdh4"
      end
    end

Links
=====

* http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/latest/CDH4-Quick-Start/cdh4qs_topic_3_3.html

License and Author
==================

- Author:: Pavel Mitin (<mitin.pavel@gmail.com>)

Copyright 2013 Pavel Mitin

Licensed under the MIT License (MIT).
