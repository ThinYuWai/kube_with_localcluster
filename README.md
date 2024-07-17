```
mkdir master node01 node02 node03
ssh-keygen
```

Update SSH KEY path in VagrantFile and Run the following Command 
```
vagrant up 
vagrant status
```

Log into ssh of control-plane node and worker node
```
vagrant ssh master 
vagrant ssh worker-node01 
vagrant ssh worker-node02 
vagrant ssh worker-node03
```

Command to run on control-plane node 
```
$ sh command.sh
$ sh master.sh

###Install CNI Calico###
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

###Modify the pod CIDR firt###
$ kubectl apply -f custom-resources.yaml
```

Command to run on worker node
```
$ sh command.sh
$ sh node.sh ( Optional )

###Join the K8s cluster###(Generated from master node)
$ sudo kubeadm join [master node ip]:6443 --token klmudq.ogr8tdkoy0n9hh2a --discovery-token-ca-cert-hash sha256:2ebd75679c5e612dce52be841fa3d85cac8caf423285977c6435f24136fe2917
```

```
$ kubectl get nodes
$ kubectl label node worker-node01 node-role.kubernetes.io/worker=worker-new
$ kubectl get all -A
```
