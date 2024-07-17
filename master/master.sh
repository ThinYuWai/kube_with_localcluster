#!/usr/bin/env bash

MASTER_IP="192.168.59.10"
NODENAME=$(hostname -s)
POD_CIDR="172.169.0.0/16"
SRV_CIDR="10.129.0.0/16"
#CILIUM_VERSION="1.12.3"

# Pull the kubernetes images
sudo kubeadm config images pull 

# Init Kubernetes
sudo kubeadm init \
--apiserver-advertise-address=$MASTER_IP  \
--apiserver-cert-extra-sans=$MASTER_IP \
--pod-network-cidr=$POD_CIDR \
--service-cidr=$SRV_CIDR \
--node-name $NODENAME

# KUBECONFIG for in-VM kubectl usage
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Untaint the control node to be used as a worker too
# kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all  node-role.kubernetes.io/control-plane-

# Generete KUBECONFIG on the host
sudo mkdir -p configs
sudo mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf configs/config
sudo cp -i configs/config /home/vagrant/.kube/
# sudo touch /vagrant/configs/join.sh
# sudo chmod +x /vagrant/configs/join.sh       

# Generete the kubeadm join command on the host
# generates a token to join worker nodes to the Kubernetes control plane and saves the join command to a file
sudo kubeadm token create --print-join-command | sudo tee configs/join.sh

# master:   mkdir -p $HOME/.kube
# master:   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# master:   sudo chown $(id -u):$(id -g) $HOME/.kube/config