#!/bin/bash


echo "Downloading and instaling fleetctl, etcdctl and kubectl ..."
# First let's check which OS we use: OS X or Linux
uname=$(uname)

if [[ "${uname}" == "Darwin" ]]
then
    # OS X
    #
mkdir ~/k8s-bin
# download etcd and fleet clients for OS X
ETCD_RELEASE=$(cat bootstrap_k8s_cluster.sh | grep ETCD_RELEASE= | head -1 | cut -f2 -d"=")
echo "Downloading etcdctl $ETCD_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/$ETCD_RELEASE/etcd-$ETCD_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-$ETCD_RELEASE-darwin-amd64/etcdctl"
mv -f etcdctl ~/k8s-bin
# clean up
rm -f etcd.zip
echo "etcdctl was copied to ~/k8s-bin"
echo " "

    #
    FLEET_RELEASE=$(ssh core@$master_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-tsc-gce/bin
    echo "Downloading fleetctl v$FLEET_RELEASE for OS X"
    curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-darwin-amd64.zip"
    unzip -j -o "fleet.zip" "fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl"
    mv -f fleetctl ~/k8s-bin
    # clean up
    rm -f fleet.zip
    echo "fleetctl was copied to ~/k8s-bin "
    echo " "

# download kubernetes client for OS X
# k8s version
k8s_version=$1
echo "Downloading kubernetes $k8s_version for OS X"
curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/$k8s_version/bin/darwin/amd64/kubectl
mv -f kubectl ~/k8s-bin
#

echo " "
echo "kubectl was copied to ~/k8s-bin"
echo " "

else
    # Linux
    #
    FLEET_RELEASE=$(ssh core@$master_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-tsc-gce/bin
    echo "Downloading fleetctl v$FLEET_RELEASE for Linux"
    wget "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-linux-amd64.tar.gz"
    tar -zxvf fleet-v$FLEET_RELEASE-linux-amd64.tar.gz fleet-v$FLEET_RELEASE-linux-amd64/fleetctl --strip 1
    rm -f fleet-v$FLEET_RELEASE-linux-amd64.tar.gz
    # Make them executable
    chmod +x ~/coreos-tsc-gce/bin/*
    #
fi
