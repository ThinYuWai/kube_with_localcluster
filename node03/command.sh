#!/usr/bin/env bash

# Define the Kubernetes version
K8S_VERSION="1.30"

# Ensure /etc/kubernetes directory exists
if [ ! -d /etc/kubernetes ]; then
    sudo mkdir -p /etc/kubernetes
fi

# Ensure /etc/apt/keyrings directory exists
if [ ! -d /etc/apt/keyrings ]; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
fi

# Add the Google Kubernetes repo
sudo apt-get update
# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add the Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Configure the Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet, kubeadm, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

# Disable swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo mount -a
free -h
(crontab -l 2>/dev/null; echo "@reboot sudo /sbin/swapoff -a") | crontab - || true

# Configure the needed modules and persist them
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start the service
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock

# Start both containerd and kubelet
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl enable kubelet
