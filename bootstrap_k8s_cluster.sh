#!/bin/bash

# SET ETCD VERSION TO BE USED !!!
ETCD_RELEASE=v0.4.6

# SET FLEET VERSION TO BE USED !!!
FLEET_RELEASE=v0.9.0

# SET KUBERNETES VERSION TO BE USED !!!
k8s_version=v0.9.2

## change Google Cloud settings as per your requirements
# GC settings

# SET YOUR PROJECT AND ZONE !!!
project=my-cloud-project
zone=europe-west1-c

# CoreOS RELEASE CHANNEL
channel=alpha

# CONTROL AND NODES MACHINE TYPES
control_machine_type=g1-small
node_machine_type=n1-standard-1
##

###
# control node name
control_name=k8s-control
# node name
node_name=k8s-node
###

# get the latest full image name
image=$(gcloud compute images list | grep -v grep | grep coreos-$channel | awk {'print $1'})

# update cloud-configs with CoreOS release channel
sed -i "" -e 's/GROUP/'$channel'/g' ./cloud-config/*.yaml
# update fleet units with k8s version
sed -i "" -e 's/k8s_version/'$k8s_version'/g' ./fleet-units/*.service
#

# CONTROL
# create control node
gcloud compute instances create $control_name \
--project=$project --image=$image --image-project=coreos-cloud \
--boot-disk-type=pd-ssd --boot-disk-size=10 --zone=$zone \
--machine-type=$control_machine_type --metadata-from-file user-data=./cloud-config/control.yaml \
--can-ip-forward --scopes compute-rw --tags k8s-cluster

# get control node internal IP
control_node_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $control_name | awk {'print $4'});

# NODES
# update node's cloud-config with control node's internal IP
sed -i "" -e 's/CONTROL-NODE-INTERNAL-IP/'$control_node_ip'/g' ./cloud-config/node.yaml

# create nodes
#  by defaul it creates two nodes, e.g. to add a third one, add after '$node_name-02' $node_name-03 and so on
gcloud compute instances create $node_name-01 $node_name-02 \
--project=$project --image=$image --image-project=coreos-cloud \
--boot-disk-type=pd-ssd --boot-disk-size=20 --zone=$zone \
--machine-type=$node_machine_type --metadata-from-file user-data=./cloud-config/node.yaml \
--can-ip-forward --tags k8s-cluster

# FLEET
# update fleet units with control node's internal IP
sed -i "" -e 's/CONTROL-NODE-INTERNAL-IP/'$control_node_ip'/g' ./fleet-units/*.service

# download etcdctl, fleetctl and k8s binaries for OS X
./get_k8s_fleet_etcd_osx.sh

# set binaries folder, fleet tunnel to control's external IP
export PATH=${HOME}/k8s-bin:$PATH
control_external_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $control_name | awk {'print $5'});
export FLEETCTL_TUNNEL="$control_external_ip"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

# deploy k8s fleet units
cd ./fleet-units
echo "Installing k8s fleet units !!!"
fleetctl start kube-kubelet.service 
fleetctl start kube-proxy.service
fleetctl start kube-apiserver.service
fleetctl start kube-controller-manager.service
fleetctl start kube-scheduler.service
fleetctl start kube-register.service
echo " "
fleetctl list-units
