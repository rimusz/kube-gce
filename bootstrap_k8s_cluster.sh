#!/bin/bash
ssh-add ~/.ssh/google_compute_engine &>/dev/null

# Create Kubernetes cluster

# Update required settings in "settings" file before running this script

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat settings | grep zone= | head -1 | cut -f2 -d"=")
# CoreOS release channel
channel=$(cat settings | grep channel= | head -1 | cut -f2 -d"=")
# master instance type
master_machine_type=$(cat settings | grep control_machine_type= | head -1 | cut -f2 -d"=")
# node instance type
node_machine_type=$(cat settings | grep worker_machine_type= | head -1 | cut -f2 -d"=")
# get the latest full image name
image=$(gcloud compute images list --project=$project | grep -v grep | grep coreos-$channel | awk {'print $1'})
#
# master name
master_name=$(cat settings | grep master_name= | head -1 | cut -f2 -d"=")
# node name
node_name=$(cat settings | grep node_name= | head -1 | cut -f2 -d"=")
###

# get latest k8s version
function get_latest_version_number {
local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/latest.txt"
if [[ $(which wget) ]]; then
  wget -qO- ${latest_url}
elif [[ $(which curl) ]]; then
  curl -Ss ${latest_url}
fi
}

k8s_version=$(get_latest_version_number)

# update cloud-configs with CoreOS release channel
sed -i "" -e 's/_GROUP_/'$channel'/g' ./cloud-config/*.yaml
# update fleet units with k8s version
sed -i "" -e 's/_K8S_VERSION_/'$k8s_version'/g' ./fleet-units/*.service
#

# master
# create master node
gcloud compute instances create $master_name \
 --project=$project --image=$image --image-project=coreos-cloud \
 --boot-disk-type=pd-ssd --boot-disk-size=10 --zone=$zone \
 --machine-type=$master_machine_type --metadata-from-file user-data=./cloud-config/master.yaml \
 --can-ip-forward --scopes compute-rw --tags k8s-cluster

# get master node internal IP
master_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $master_name | awk {'print $4'});

# NODES
# update node's cloud-config with master node's internal IP
sed -i "" -e 's/_MASTER-NODE-INTERNAL-IP_/'$master_ip'/g' ./cloud-config/node.yaml

# create nodes
#  by defaul it creates two nodes, e.g. to add a third one, add after '$node_name-02' $node_name-03 and so on
gcloud compute instances create $node_name-01 $node_name-02 \
 --project=$project --image=$image --image-project=coreos-cloud \
 --boot-disk-type=pd-ssd --boot-disk-size=20 --zone=$zone \
 --machine-type=$node_machine_type --metadata-from-file user-data=./cloud-config/node.yaml \
 --can-ip-forward --tags k8s-cluster

# FLEET
# update fleet units with master node's internal IP
sed -i "" -e 's/_MASTER-INTERNAL-IP_/'$master_ip'/g' ./fleet-units/*.service


# set binaries folder, fleet tunnel to master's external IP
export PATH=${HOME}/k8s-bin:$PATH
master_external_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $master_name | awk {'print $5'});
export FLEETCTL_TUNNEL="$master_external_ip"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

# download etcdctl, fleetctl and k8s binaries for OS X/Linux
./get_k8s_fleet_etcd.sh $k8s_version $master_ip

# deploy k8s fleet units
cd ./fleet-units
echo "Installing k8s fleet units !!!"
fleetctl start kube-apiserver.service
fleetctl start kube-controller-manager.service
fleetctl start kube-scheduler.service
fleetctl start kube-register.service
fleetctl start kube-kubelet.service 
fleetctl start kube-proxy.service
echo " "
fleetctl list-units

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
