# -*- mode: ruby -*-
# vi: set ft=ruby :
NUM_WORKER_NODES    = 3
NUM_MASTER_NODES    = 3
IP_NW="192.168.59."
IP_START=10
CPUS_MASTER_NODE    = 4
MEMORY_MASTER_NODE  = 2048
CPUS_WORKER_NODE    = 2
MEMORY_WORKER_NODE  = 1024
VAGRANT_BOX_IMAGE   = "bento/ubuntu-23.04"

Vagrant.configure("2") do |config|

  config.vm.provision "shell", env: {"IP_NW" => IP_NW, "IP_START" => IP_START}, inline: <<-SHELL
      apt-get update -y
      echo "$IP_NW$((IP_START))  master-node  master-node.wesquaretech.com" >> /etc/hosts
      echo "$IP_NW$((IP_START+1))  worker-node01  worker-node01.wesquaretech.com" >> /etc/hosts
      echo "$IP_NW$((IP_START+2))  worker-node02  worker-node02.wesquaretech.com" >> /etc/hosts
      echo "$IP_NW$((IP_START+3))  worker-node03  worker-node03.wesquaretech.com" >> /etc/hosts
  SHELL

  config.vm.define "master" do |master|
    config.ssh.private_key_path = "/Users/yuthin/Learning/vagrantboxes/.ssh/id_rsa"
    config.ssh.forward_agent = true
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    master.vm.box = VAGRANT_BOX_IMAGE
    master.vm.hostname = "master-node.wesquaretech.com"
    master.vm.synced_folder "./master", "/home/vagrant/"
    master.vm.network "private_network", ip: IP_NW + "#{IP_START}"
    master.vm.provider "virtualbox" do |vb|
      vb.name = "master-node"
      vb.cpus = CPUS_MASTER_NODE
      vb.memory = MEMORY_MASTER_NODE
      vb.gui = false
    end
      master.vm.provision "shell", run: "always", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release bash-completion -y
        netstat -tunlp
        echo "Hello from Master-node"
      SHELL
  end


  (1..NUM_WORKER_NODES).each do |i|

    config.vm.define "node0#{i}" do |node|
    config.ssh.private_key_path = "/Users/yuthin/Learning/vagrantboxes/.ssh/id_rsa"
    config.ssh.forward_agent = true
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
      node.vm.hostname = "worker-node0#{i}.wesquaretech.com"
      node.vm.box = VAGRANT_BOX_IMAGE
      node.vm.synced_folder "./node0#{i}", "/home/vagrant/"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "worker-node0#{i}"
        vb.cpus = CPUS_WORKER_NODE
        vb.memory = MEMORY_WORKER_NODE
        vb.gui = false
      end
      node.vm.provision "shell", run: "always", inline: <<-SHELL
        sudo apt-get update
        sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release bash-completion -y
        netstat -tunlp
        echo "Hello from Worker-node#{i}"
      SHELL
    end
  end
end
