#!/usr/bin/env bash
# Ensure /root/.kube directory exists
if [ ! -d /root/.kube ]; then
    sudo mkdir -p /root/.kube
fi

NODENAME=$(hostname -s)

# Join the control node
#sudo /bin/bash configs/join.sh -v

# KUBECONFIG for in-VM kubectl usage
sudo -i -u vagrant bash << EOF
mkdir -p $HOME/.kube
#sudo cp -i configs/config $HOME/.kube/
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker-new
EOF

# sudo chown 1000:1000 /home/vagrant/.kube/config
# https://github.com/cilium/cilium/issues/18670#issuecomment-1028686663
# Partial fix: you need to modify /etc/systemd/system/kubelet.service.d/10-kubeadm.conf and add the line
# Environment="KUBELET_EXTRA_ARGS=--node-ip=_YOUR_NODE_IP"
# Kubeadm clusters want to grab the lowest IP possible to bind to by default, which is normally not the routeable node ip and is instead vagrant.

# Join the control node(Collect from Master)
# kubeadm join xxxxx
# kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker-new